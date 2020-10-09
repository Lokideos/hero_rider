# frozen_string_literal: true

class Game < Sequel::Model
  # TODO: move all trophy related stuff to goddman trophy models
  TROPHIES_WEIGHT = {
    bronze: 15,
    silver: 30,
    gold: 90,
    platinum: 300
  }.freeze
  GAME_CACHE_EXPIRE = 300
  SLOWEST_PLATINUM_MARKER = 'slowest'
  FASTEST_PLATINUM_MARKER = 'fastest'

  one_to_many :game_acquisitions
  one_to_many :trophies
  many_to_many :players, left_key: :game_id, right_key: :player_id, join_table: :game_acquisitions

  dataset_module do
    def precise_game_search(title)
      select(:game_id, :trophy_service_id, :title, :platform)
      where(Sequel.ilike(:title, "#{title}%"))
        .inner_join(:game_acquisitions, game_id: :id)
        .reverse_order(:last_updated_date)
        .limit(1)
        .first
    end

    def generic_game_search(title)
      select(:game_id, :trophy_service_id, :title, :platform)
      where(Sequel.ilike(:title, "%#{title.split(' ')[0..2].join('%')}%"))
        .inner_join(:game_acquisitions, game_id: :id)
        .reverse_order(:last_updated_date)
        .limit(1)
        .first
    end

    def trigram_game_search(title)
      safe_title = Sequel::Model.db.literal(title)
      with_sql(
        'SELECT g.id game_id, g.icon_url, g.trophy_service_id, g.title, g.platform ' \
          'FROM games g ' \
          'INNER JOIN game_acquisitions ga ON ga.game_id = g.id ' \
          "WHERE (g.title % #{safe_title}) " \
          "ORDER BY similarity(g.title, #{safe_title}), ga.last_updated_date DESC " \
          'LIMIT 1'
      ).first
    end

    def precise_games_search(title)
      select(:game_id, :trophy_service_id, :title, :platform)
        .where(Sequel.ilike(:title, "#{title}%"))
        .inner_join(:game_acquisitions, game_id: :id)
        .reverse_order(:last_updated_date)
        .all
    end

    def generic_games_search(title)
      select(:game_id, :trophy_service_id, :title, :platform)
        .where(Sequel.ilike(:title, "%#{title.split(' ')[0..2].join('%')}%"))
        .inner_join(:game_acquisitions, game_id: :id)
        .reverse_order(:last_updated_date)
        .all
    end

    def trigram_games_search(title)
      safe_title = Sequel::Model.db.literal(title)
      with_sql(
        'SELECT g.id game_id, g.trophy_service_id, g.title, g.platform ' \
          'FROM games g ' \
          'INNER JOIN game_acquisitions ga ON ga.game_id = g.id ' \
          "WHERE (g.title % #{safe_title}) " \
          "ORDER BY similarity(g.title, #{safe_title}), ga.last_updated_date DESC"
      )
    end
  end

  class << self
    def relevant_games(title, player_name)
      return unless title.length > 1

      games = (precise_games_search(title) + generic_games_search(title)).uniq[0..9]
      games = trigram_games_search(title).uniq[0..9] unless games.present?

      games.each_with_index do |game, index|
        RedisDb.redis.setex("holy_rider:top:#{player_name}:games:#{index + 1}",
                            GAME_CACHE_EXPIRE,
                            game.trophy_service_id)
        RedisDb.redis.sadd("holy_rider:top:#{player_name}:games",
                           "holy_rider:top:#{player_name}:games:#{index + 1}")
      end

      games
    end

    def find_game_from_cache(player, index)
      game_trophy_id = RedisDb.redis.get("holy_rider:top:#{player}:games:#{index}")
      return unless game_trophy_id

      game = Game.find(trophy_service_id: game_trophy_id)
      top_game(game)
    end

    def find_last_game
      game = TrophyAcquisition.exclude(earned_at: nil).order(:earned_at).last.trophy.game
      top_game(game)
    end

    def cached_game_top(game)
      cached_top = RedisDb.redis.get("holy_rider:top:game:#{game[:trophy_service_id]}")
      return unless cached_top

      Oj.load(cached_top, {})
    end

    # TODO: this should be on object level - not on class level
    def store_game_top(game)
      game_id = game.values[:game_id] || game.id
      progresses = GameAcquisition.find_progresses(game_id)

      prepared_progresses = progresses.map do |progress|
        platinum_earned_date = TrophyAcquisition
                               .platinum_game_acquisition(game_id, progress.player_id)&.earned_at
        first_trophy_earned_date = TrophyAcquisition
                                   .first_game_acquisition(game_id, progress.player_id)&.earned_at
        OpenStruct.new(
          trophy_account: progress.values.dig(:trophy_account),
          progress: progress.values.dig(:progress),
          first_trophy_earned_date: first_trophy_earned_date,
          platinum_earning_date: platinum_earned_date,
          platinum_placement: nil,
          platinum_speed: nil
        )
      end

      add_platinum_placement(prepared_progresses)
      add_platinum_speed(prepared_progresses)
      grouped_progresses = prepared_progresses.group_by(&:progress)

      grouped_progresses.each_key do |progress_group|
        player_progresses = grouped_progresses[progress_group]
        grouped_progresses[progress_group] = [
          player_progresses.select(&:platinum_earning_date).sort do |left_player, right_player|
            left_player.platinum_earning_date <=> right_player.platinum_earning_date
          end,
          player_progresses.select { |progress| progress.platinum_earning_date.blank? }
        ].flatten
      end
      game_top = {
        'game' => {
          'icon_url' => game.icon_url,
          'title' => game.title,
          'platform' => game.platform
        },
        'progresses' => grouped_progresses.values.flatten.map do |progress|
          {
            'trophy_account' => progress.trophy_account,
            'progress' => progress.progress,
            'platinum_earning_date' => progress.platinum_earning_date,
            'platinum_placement' => progress.platinum_placement,
            'platinum_speed' => progress.platinum_speed
          }
        end
      }
      RedisDb.redis.set("holy_rider:top:game:#{game[:trophy_service_id]}", Oj.dump(game_top))

      game_top
    end

    # TODO: refactoring needed!
    def top_game(game)
      return unless game.present?

      top_is_cached?(game) ? cached_game_top(game) : store_game_top(game)
    end

    def update_all_progress_caches
      Game.all.each do |game|
        Game.store_game_top(game)
      end
    end

    def players_with_platinum_trophy(game_id)
      find(id: game_id).trophies.find { |trophy| trophy.trophy_type == 'platinum' }&.players
    end

    def top_is_cached?(game)
      RedisDb.redis.exists?("holy_rider:top:game:#{game[:trophy_service_id]}")
    end

    def add_platinum_speed(progresses)
      sorted_progresses = sorted_by_speed_progresses(progresses)
      return unless sorted_progresses.present?

      sorted_progresses.first.platinum_speed = FASTEST_PLATINUM_MARKER
      return if sorted_progresses.size < 2

      sorted_progresses.last.platinum_speed = SLOWEST_PLATINUM_MARKER
    end

    def add_platinum_placement(progresses)
      sorted_progresses = sorted_platinum_progresses(progresses)
      return unless sorted_progresses.present?

      sorted_progresses[0..2].each_with_index do |progress, index|
        progress.platinum_placement = index + 1
      end
    end

    def sorted_platinum_progresses(progresses)
      progresses.select(&:platinum_earning_date).sort do |left_progress, right_progress|
        left_progress.platinum_earning_date <=> right_progress.platinum_earning_date
      end
    end

    def sorted_by_speed_progresses(progresses)
      progresses.select(&:platinum_earning_date).sort do |left_progress, right_progress|
        (left_progress.platinum_earning_date - left_progress.first_trophy_earned_date) <=>
          (right_progress.platinum_earning_date - right_progress.first_trophy_earned_date)
      end
    end
  end

  # TODO: probably should optimize that
  def trophy_points_by_player(player)
    player_trophies_ids = player.trophy_acquisitions.map(&:trophy_id)
    trophies.select { |trophy| player_trophies_ids.include? trophy.id }.map do |trophy|
      TROPHIES_WEIGHT[trophy.trophy_type.to_sym]
    end.inject(0, :+)
  end

  def total_trophy_points
    trophies.map do |trophy|
      TROPHIES_WEIGHT[trophy.trophy_type.to_sym]
    end.inject(0, :+)
  end

  def update_top_progresses
    players.each do |player|
      progress = (trophy_points_by_player(player).to_f / total_trophy_points.to_f * 100).floor
      game_acquisitions.find do |acquisition|
        acquisition.player_id == player.id
      end.update(progress: progress)
    end

    Game.store_game_top(self)
  end
end
