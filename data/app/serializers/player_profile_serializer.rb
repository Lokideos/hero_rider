# frozen_string_literal: true

module PlayerProfileSerializer
  module_function

  def serialize(player)
    profile = player.profile
    {
      telegram_name: player.telegram_username,
      trophy_account: player.trophy_account,
      trophy_level: profile[:trophy_level],
      level_up_progress: profile[:level_up_progress],
      games_count: profile[:games].count,
      trophy_total: profile[:trophies][:total].count + profile[:hidden_trophies][:total].count,
      uniq_plats: profile[:unique_platinums],
      trophies: {
        platinum: profile[:trophies][:platinum].count,
        gold: profile[:trophies][:gold].count,
        silver: profile[:trophies][:silver].count,
        bronze: profile[:trophies][:bronze].count,
        total: profile[:trophies][:total].count
      },
      hidden_trophies: {
        platinum: profile[:hidden_trophies][:platinum].count,
        gold: profile[:hidden_trophies][:gold].count,
        silver: profile[:hidden_trophies][:silver].count,
        bronze: profile[:hidden_trophies][:bronze].count,
        total: profile[:hidden_trophies][:total].count
      }
    }
  end
end
