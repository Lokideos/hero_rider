# frozen_string_literal: true

# TODO: hidden trophy service should be only about hidden trophies -
# TODO: move gathering of trophy level and progress to separate service
module Watcher
  class AddHiddenTrophiesService
    prepend BasicService

    TROPHY_TYPES = %w[platinum gold silver bronze].freeze

    option :player_name
    option :hunter_name
    option :player, default: proc { Player.find(trophy_account: @player_name) }
    option :token, default: proc {
      RedisDb.redis.get("holy_rider:trophy_hunter:#{@hunter_name}:access_token")
    }
    option :client, default: proc {
      PsnService::V2::HttpClient.new(url: Settings.psn.v2.trophies.url)
    }

    def call
      trophy_summary = @client.request_trophy_summary(user_id: @player.trophy_user_id,
                                                      token: @token)
      @player.update(trophy_level: trophy_summary['trophyLevel'],
                     level_up_progress: trophy_summary['progress'])
      return if player_in_initial_load?(@player_name)

      @player.delete_hidden_trophies

      TROPHY_TYPES.each do |trophy_type|
        trophy_type_count = trophy_summary['earnedTrophies'][trophy_type] -
                            @player.all_trophies_by_type(trophy_type).count
        save_hidden_trophies(@player, trophy_type, trophy_type_count)
      end
    end

    private

    def player_in_initial_load?(player_name)
      RedisDb.redis.exists?("holy_rider:watcher:players:initial_load:#{player_name}")
    end

    def save_hidden_trophies(player, trophy_type, count)
      count.times do
        player.add_trophy(Trophy.create(trophy_service_id: 0,
                                        trophy_name: 'hidden',
                                        trophy_description: 'hidden',
                                        trophy_type: trophy_type,
                                        trophy_icon_url: 'hidden',
                                        trophy_small_icon_url: 'hidden',
                                        trophy_earned_rate: 'hidden',
                                        trophy_rare: 3,
                                        hidden: true))
      end
    end
  end
end
