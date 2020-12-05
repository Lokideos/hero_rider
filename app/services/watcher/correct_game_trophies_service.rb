# frozen_string_literal: true

module Watcher
  class CorrectGameTrophiesService
    prepend BasicService

    option :player
    option :token
    option :game
    option :new_trophy_ids
    option :client, default: proc {
      PsnService::V2::HttpClient.new(url: Settings.psn.v2.trophies.url)
    }

    def call
      game_trophies_list = @client.request_game_trophy_list(
        token: @token, game_id: id, trophy_service_source: game.trophy_service_source
      )
      additional_trophies_info = @client.request_game_player_trophies(
        user_id: @player.trophy_user_id, token: @token, game_id: id,
        trophy_service_source: game.trophy_service_source
      )
      trophies_list = merge_trophies(game_trophies_list, additional_trophies_info)

      new_trophies = trophies_list.select do |trophy|
        @new_trophy_ids.include? trophy['trophyId']
      end

      Workers::ProcessProgressesUpdate.perform_async(@game.id)

      new_trophies.each do |trophy|
        @game.add_trophy(Trophy.create(trophy_name: trophy['trophyName'],
                                       trophy_service_id: trophy['trophyId'],
                                       trophy_description: trophy['trophyDetail'],
                                       trophy_type: trophy['trophyType'],
                                       trophy_icon_url: trophy['trophyIconUrl'],
                                       trophy_small_icon_url: trophy['trophyIconUrl'],
                                       trophy_earned_rate: trophy['trophyEarnedRate'],
                                       trophy_rare: trophy['trophyRare']))
      end
    end

    private

    def merge_trophies(game_trophies, trophies_info)
      game_trophies.map do |trophy|
        trophy.merge(
          trophies_info.find { |trophy_info| trophy_info['trophyId'] == trophy['trophyId'] }
        )
      end
    end
  end
end
