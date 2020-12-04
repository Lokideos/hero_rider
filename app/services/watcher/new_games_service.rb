# frozen_string_literal: true

module Watcher
  class NewGamesService
    prepend BasicService

    option :player_name
    option :token
    option :updates
    option :player, default: proc { Player.find(trophy_account: @player_name) }
    option :client, default: proc {
      PsnService::V1::HttpClient.new(url: Settings.psn.v1.game_trophies.url)
    }

    def call
      trophy_service_ids = @updates['trophyTitles'].map { |game| game['npCommunicationId'] }
      new_games_trophy_ids = trophy_service_ids - Game.map(:trophy_service_id)

      new_games_trophy_ids.each do |id|
        new_game = @updates['trophyTitles'].find { |game| game['npCommunicationId'] == id }

        extended_trophies_list = @client.request_game_trophy_list(
          player_name: @player.trophy_account, token: @token, game_id: id, extended: true
        )

        prepared_game_title = prepare_game_title(new_game['trophyTitleName'])

        game = Game.create(trophy_service_id: id, title: prepared_game_title,
                           platform: new_game['trophyTitlePlatfrom'],
                           icon_url: new_game['trophyTitleIconUrl'])

        # TODO: find import (bulk_upload) in sequel and use it to query all trophies to db
        # TODO: It's called import for Christ sake. How didn't I find it before
        extended_trophies_list.each do |trophy|
          game.add_trophy(Trophy.create(trophy_name: trophy['trophyName'],
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

    private

    def prepare_game_title(game_title)
      game_title.gsub(/[\u2122\u00ae\n]/, ' ').gsub(/  /, ' ').strip
    end
  end
end
