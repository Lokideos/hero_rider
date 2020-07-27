# frozen_string_literal: true

class Player < Sequel::Model
  RARE_TROPHIES_WEIGHTS = {
    0 => {
      bronze: 45,
      silver: 90,
      gold: 270,
      platinum: 2700
    },
    1 => {
      bronze: 15,
      silver: 30,
      gold: 90,
      platinum: 180
    },
    2 => {
      bronze: 15,
      silver: 30,
      gold: 90,
      platinum: 180
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
    platinum: 180
  }.freeze

  one_to_many :game_acquisitions
  one_to_many :trophy_acquisitions
  many_to_many :games, left_key: :player_id, right_key: :game_id, join_table: :game_acquisitions
  many_to_many :trophies, left_key: :player_id, right_key: :trophy_id,
                          join_table: :trophy_acquisitions
  one_to_many :message_thread

  dataset_module do
    def active
      where(on_watch: true)
    end

    def active_trophy_accounts
      where(on_watch: true).map(:trophy_account)
    end

    def last_updated_game_ids(trophy_account, service_ids)
      where(trophy_account: trophy_account)
        .inner_join(:game_acquisitions, player_id: :id)
        .inner_join(:games, id: :game_id)
        .where(trophy_service_id: service_ids)
        .map(:last_updated_date)
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
    redis = HolyRider::Application.instance.redis
    redis.keys('holy_rider:players:trophy_points:*').each do |key|
      redis.del(key)
    end

    trophy_top_rare
    trophy_top
  end

  def rare_points
    redis = HolyRider::Application.instance.redis
    redis.get("holy_rider:players:trophy_points:rare:#{trophy_account}")
  end

  def update_rare_points
    redis = HolyRider::Application.instance.redis
    rare_points = trophies.map do |trophy|
      RARE_TROPHIES_WEIGHTS[trophy.trophy_rare][trophy.trophy_type.to_sym]
    end.inject(0, :+).to_s.chop
    redis.set("holy_rider:players:trophy_points:rare:#{trophy_account}", rare_points)

    rare_points
  end

  def trophy_points
    redis = HolyRider::Application.instance.redis
    redis.get("holy_rider:players:trophy_points:common:#{trophy_account}")
  end

  def update_trophy_points
    redis = HolyRider::Application.instance.redis
    trophy_points = trophies.map do |trophy|
      TROPHIES_WEIGHT[trophy.trophy_type.to_sym]
    end.inject(0, :+)
    redis.set("holy_rider:players:trophy_points:common:#{trophy_account}", trophy_points)

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
      unique_platinums: unique_platinum_count
    }
  end

  def unique_platinum_count
    platinum_trophy_ids = trophies.select { |trophy| trophy.trophy_type == 'platinum' }.map(&:id)
    acquisitions = TrophyAcquisition.where(trophy_id: platinum_trophy_ids).all.group_by(&:trophy_id)
    acquisitions.select { |_trophy_id, player_with_trophy| player_with_trophy.size == 1 }.size
  end
end
