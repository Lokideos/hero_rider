# frozen_string_literal: true

class Player < Sequel::Model
  RARE_TROPHIES_WEIGHTS = {
    0 => {
      bronze: 45,
      silver: 90,
      gold: 270,
      platinum: 4500
    },
    1 => {
      bronze: 15,
      silver: 30,
      gold: 90,
      platinum: 300
    },
    2 => {
      bronze: 15,
      silver: 30,
      gold: 90,
      platinum: 300
    },
    3 => {
      bronze: 0,
      silver: 0,
      gold: 0,
      platinum: 0
    }
  }.freeze

  TROPHIES_WEIGHT = {
    bronze: 15,
    silver: 30,
    gold: 90,
    platinum: 300
  }.freeze

  one_to_many :game_acquisitions
  one_to_many :trophy_acquisitions
  many_to_many :games, left_key: :player_id, right_key: :game_id, join_table: :game_acquisitions
  many_to_many :trophies, left_key: :player_id, right_key: :trophy_id,
                          join_table: :trophy_acquisitions
  one_to_many :message_thread
  one_to_many :responsible_for_repairs

  def validate
    super
    validates_presence :telegram_username, message: I18n.t(:blank,
                                                           scope: 'models.errors.player.username')
  end

  dataset_module do
    def active
      where(on_watch: true)
    end

    def active_trophy_accounts
      where(on_watch: true).all
    end

    def last_updated_game_ids(trophy_account, service_ids)
      where(trophy_account: trophy_account)
        .inner_join(:game_acquisitions, player_id: :id)
        .inner_join(:games, id: :game_id)
        .where(trophy_service_id: service_ids)
        .map(:last_updated_date)
    end

    def uniq_plat_count(trophy_account)
      safe_account = Sequel::Model.db.literal(trophy_account)
      with_sql(
        "SELECT COUNT(*) unique_platinum_count
         FROM (
           SELECT g.title
           FROM players p
           INNER JOIN trophy_acquisitions ta ON ta.player_id = p.id
           INNER JOIN trophies t ON t.id = ta.trophy_id
           INNER JOIN games g ON g.id = t.game_id
           WHERE p.trophy_account = #{safe_account} AND t.trophy_type = 'platinum'
           EXCEPT
           SELECT g.title
           FROM players p
           INNER JOIN trophy_acquisitions ta ON ta.player_id = p.id
           INNER JOIN trophies t ON t.id = ta.trophy_id
           INNER JOIN games g ON g.id = t.game_id
           WHERE p.trophy_account != #{safe_account} AND t.trophy_type = 'platinum'
         ) AS games_with_uniq_plats"
      ).map(:unique_platinum_count).first
    end

    def uniq_plat_games(trophy_account)
      safe_account = Sequel::Model.db.literal(trophy_account)
      with_sql(
        "SELECT games_with_uniq_plats.title
         FROM (
           SELECT g.title
           FROM players p
           INNER JOIN trophy_acquisitions ta ON ta.player_id = p.id
           INNER JOIN trophies t ON t.id = ta.trophy_id
           INNER JOIN games g ON g.id = t.game_id
           WHERE p.trophy_account = #{safe_account} AND t.trophy_type = 'platinum'
           EXCEPT
           SELECT g.title
           FROM players p
           INNER JOIN trophy_acquisitions ta ON ta.player_id = p.id
           INNER JOIN trophies t ON t.id = ta.trophy_id
           INNER JOIN games g ON g.id = t.game_id
           WHERE p.trophy_account != #{safe_account} AND t.trophy_type = 'platinum'
         ) AS games_with_uniq_plats"
      ).map(:title)
    end
  end

  def self.trophy_top
    Player.all.map do |player|
      name = player.trophy_account
      telegram_name = player.telegram_username
      points = player.trophy_points ? player.trophy_points.to_i : player.update_trophy_points
      {
        trophy_account: name,
        telegram_username: telegram_name,
        points: points
      }
    end.sort { |left_player, right_player| right_player[:points] <=> left_player[:points] }
  end

  def self.trophy_top_rare
    Player.all.map do |player|
      name = player.trophy_account
      telegram_name = player.telegram_username
      points = player.rare_points ? player.rare_points.to_i : player.update_rare_points
      {
        trophy_account: name,
        telegram_username: telegram_name,
        points: points
      }
    end.sort { |left_player, right_player| right_player[:points] <=> left_player[:points] }
  end

  def self.trophy_top_force_update
    RedisDb.redis.keys('holy_rider:players:trophy_points:*').each do |key|
      RedisDb.redis.del(key)
    end

    trophy_top_rare
    trophy_top
  end

  def rare_points
    RedisDb.redis.get("holy_rider:players:trophy_points:rare:#{trophy_account}")
  end

  def update_rare_points
    rare_points = trophies.map do |trophy|
      RARE_TROPHIES_WEIGHTS[trophy.trophy_rare][trophy.trophy_type.to_sym]
    end.inject(0, :+).to_s.chop
    RedisDb.redis.set("holy_rider:players:trophy_points:rare:#{trophy_account}", rare_points)

    rare_points
  end

  def trophy_points
    RedisDb.redis.get("holy_rider:players:trophy_points:common:#{trophy_account}")
  end

  def update_trophy_points
    trophy_points = trophies.map do |trophy|
      TROPHIES_WEIGHT[trophy.trophy_type.to_sym]
    end.inject(0, :+)
    RedisDb.redis.set("holy_rider:players:trophy_points:common:#{trophy_account}", trophy_points)

    trophy_points
  end

  def delete_hidden_trophies
    trophies.select { |trophy| trophy.trophy_icon_url == 'hidden' }.each do |trophy|
      remove_trophy(trophy)
      trophy.delete
    end
  end

  def admin?
    admin
  end

  def trophy_ping_on?
    trophy_ping
  end

  def on_watch?
    on_watch
  end

  def trophies_by_type(trophy_type, hidden: false)
    trophies.select { |trophy| trophy.trophy_type == trophy_type && trophy.hidden == hidden }
  end

  def all_public_trophies
    trophies.select { |trophy| trophy.hidden == false }
  end

  def all_hidden_trophies
    trophies.select { |trophy| trophy.hidden == true }
  end

  def all_trophies_by_type(trophy_type)
    trophies.select { |trophy| trophy.trophy_type == trophy_type }
  end

  def profile
    {
      trophies: {
        bronze: trophies_by_type('bronze'),
        silver: trophies_by_type('silver'),
        gold: trophies_by_type('gold'),
        platinum: trophies_by_type('platinum'),
        total: all_public_trophies
      },
      hidden_trophies: {
        bronze: trophies_by_type('bronze', hidden: true),
        silver: trophies_by_type('silver', hidden: true),
        gold: trophies_by_type('gold', hidden: true),
        platinum: trophies_by_type('platinum', hidden: true),
        total: all_hidden_trophies
      },
      games: games,
      trophy_level: trophy_level,
      level_up_progress: level_up_progress,
      unique_platinums: Player.uniq_plat_count(trophy_account)
    }
  end
end
