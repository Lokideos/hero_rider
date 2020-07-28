# frozen_string_literal: true

class Game < Sequel::Model
  # TODO: move all trophy related stuff to goddman trophy models
  TROPHIES_WEIGHT = {
    bronze: 15,
    silver: 30,
    gold: 90,
    platinum: 180
  }.freeze

  GAME_CACHE_EXPIRE = 300

  one_to_many :game_acquisitions
  one_to_many :trophies
  many_to_many :players, left_key: :game_id, right_key: :player_id, join_table: :game_acquisitions

  dataset_module do
    # TODO: try to combine datasets
    def find_game(term1, term2: nil, term3: nil, platform: nil)
      unless platform
        return where([:title, term1], [:title, term2], [:title, term3])
               .left_join(:game_acquisitions, game_id: :id)
               .order(:last_updated_date)
               .reverse
               .limit(1)
               .first
      end

      where([:title, term1], [:title, term2], [:title, term3], [:platform, platform])
        .left_join(:game_acquisitions, game_id: :id)
        .order(:last_updated_date)
        .reverse
        .limit(1)
        .first
    end

    def find_exact_game(title, platform)
      where(title: title, platform: platform)
        .left_join(:game_acquisitions, game_id: :id)
        .limit(1)
        .first
    end

    def find_games(term1, term2: nil, term3: nil)
      where([:title, term1], [:title, term2], [:title, term3])
        .left_join(:game_acquisitions, game_id: :id)
        .order(:last_updated_date)
        .reverse
        .map { |record| record.title + " #{record.platform}" }
    end
  end

  def self.relevant_games(title, message, message_type)
    return unless title.length > 1

    first_games = find_games(/^#{title}.*/i).uniq[0..9]
    second_games = []
    query_size = first_games.size
    split_title = title.split(' ')[0..2]
    if query_size < 10
      second_games = find_games(/.*#{split_title[0]}.*/i,
                                term2: /.*#{split_title[1]}.*/i,
                                term3: /.*#{split_title[2]}.*/i).uniq[0..(9 - query_size)]
    end

    player = message[message_type]['from']['username']
    all_games = (first_games << second_games).flatten.uniq
    RedisDb.redis.smembers("holy_rider:top:#{player}:games").each do |key|
      RedisDb.redis.del(key)
    end
    all_games.each_with_index do |game_title, index|
      RedisDb.redis.setex("holy_rider:top:#{player}:games:#{index + 1}",
                          GAME_CACHE_EXPIRE,
                          game_title)
      RedisDb.redis.sadd("holy_rider:top:#{player}:games",
                         "holy_rider:top:#{player}:games:#{index + 1}")
    end

    all_games
  end

  def self.find_game_from_cache(player, index)
    game = RedisDb.redis.get("holy_rider:top:#{player}:games:#{index}")
    return unless game

    game_title = game.split(' ')[0..-2].join(' ')
    game_platform = game.split(' ').last
    top_game(game_title, platform: game_platform, exact: true) if game_title
  end

  def self.find_last_game
    game = TrophyAcquisition.exclude(earned_at: nil).order(:earned_at).last.trophy.game
    top_game(game.title, platform: game.platform, exact: true)
  end

  def self.cached_game_top(game)
    JSON(RedisDb.redis.get("holy_rider:top:game:#{game.values.dig(:trophy_service_id)}"))
  end

  # TODO: this should be on object level - not on class level
  def self.store_game_top(game)
    game_id = game.values.dig(:game_id)

    progresses = GameAcquisition.find_progresses(game_id)
    platinum = Trophy.find(game_id: game.values.dig(:game_id), trophy_type: 'platinum')

    grouped_progresses = progresses.map do |progress|
      OpenStruct.new(
        trophy_account: progress.values.dig(:trophy_account),
        progress: progress.values.dig(:progress),
        platinum_earning_date: TrophyAcquisition.find(
          trophy_id: platinum&.id,
          player_id: progress.values.dig(:player_id)
        )&.earned_at
      )
    end.group_by(&:progress)

    grouped_progresses.each_key do |progress_group|
      player_progresses = grouped_progresses[progress_group]
      grouped_progresses[progress_group] = [
        player_progresses.select(&:platinum_earning_date).sort do |left_player, right_player|
          left_player.platinum_earning_date <=> right_player.platinum_earning_date
        end,
        player_progresses.select { |player_progress| player_progress.platinum_earning_date.nil? }
      ].flatten
    end
    game_top = {
      game: {
        icon_url: game.icon_url,
        title: game.title,
        platform: game.platform
      },
      progresses: grouped_progresses.values.flatten.map do |progress|
        {
          trophy_account: progress.trophy_account,
          progress: progress.progress,
          platinum_earning_date: progress.platinum_earning_date
        }
      end
    }
    RedisDb.redis.set("holy_rider:top:game:#{game.values.dig(:trophy_service_id)}",
                      game_top.to_json)

    game_top
  end

  # TODO: refactoring needed!
  def self.top_game(title, platform: nil, exact: false)
    return unless title.length > 1

    title = title.strip

    # TODO: refactoring needed
    game = if exact
             find_exact_game(title, platform)
           else
             game = non_exact_full_title_search(title)
             unless game
               split_title = title.split(' ')[0..2]
               game = find_game(/^#{title}.*/i, platform: platform) ||
                      find_game(/.*#{split_title[0]}.*/i,
                                term2: /.*#{split_title[1]}.*/i,
                                term3: /.*#{split_title[2]}.*/i,
                                platform: platform)
             end

             game
           end
    return unless game

    cached_game_top(game) || store_game_top(game)
  end

  def self.non_exact_full_title_search(title)
    Game.where(title: /^#{title}$/i).left_join(:game_acquisitions, game_id: :id).first
  end

  def self.update_all_progress_caches
    Game.all.each do |game|
      Game.store_game_top(Game.find_exact_game(game.title, game.platform))
    end
  end

  def self.players_with_platinum_trophy(game_id)
    find(id: game_id).trophies.find { |trophy| trophy.trophy_type == 'platinum' }&.players
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

    Game.store_game_top(Game.find_exact_game(title, platform))
  end
end
