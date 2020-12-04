# frozen_string_literal: true

module Watcher
  class CorrectGameTrophiesService
    prepend BasicService

    option :player
    option :token
    option :game
    option :new_trophy_ids
    option :client, default: proc {
      PsnService::V1::HttpClient.new(url: Settings.psn.game_trophies.url)
    }

    def call
      extended_trophies_list = @client.request_game_trophy_list(player_name: @player.trophy_account,
                                                                token: @token,
                                                                game_id: @game.trophy_service_id,
                                                                extended: true)

      new_trophies = extended_trophies_list.select do |trophy|
        @new_trophy_ids.include? trophy['trophyId']
      end

      Workers::ProcessProgressesUpdate.perform_async(@game.id)

      new_trophies.each do |trophy|
        @game.add_trophy(Trophy.create(trophy_name: trophy['trophyName'],
                                       trophy_service_id: trophy['trophyId'],
                                       trophy_description: trophy['trophyDetail'],
                                       trophy_type: trophy['trophyType'],
                                       trophy_icon_url: trophy['trophyIconUrl'],
                                       trophy_small_icon_url: trophy['trophySmallIconUrl'],
                                       trophy_earned_rate: trophy['trophyEarnedRate'],
                                       trophy_rare: trophy['trophyRare']))
      end
    end
  end
end
