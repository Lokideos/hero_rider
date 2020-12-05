# frozen_string_literal: true

module Watcher
  class NewGamesService
    prepend BasicService

    option :player_name
    option :token
    option :updates
    option :player, default: proc { Player.find(trophy_account: @player_name) }
    option :client, default: proc {
      PsnService::V2::HttpClient.new(url: Settings.psn.v2.trophies.url)
    }

    def call
      trophy_service_ids = @updates['trophyTitles'].map { |game| game['npCommunicationId'] }
      new_games_trophy_ids = trophy_service_ids - Game.map(:trophy_service_id)

      new_games_trophy_ids.each do |id|
        new_game = @updates['trophyTitles'].find { |game| game['npCommunicationId'] == id }

        prepared_game_title = prepare_game_title(new_game['trophyTitleName'])

        game = Game.create(trophy_service_id: id,
                           title: prepared_game_title,
                           trophy_service_source: new_game['npServiceName'],
                           platform: new_game['trophyTitlePlatform'],
                           icon_url: new_game['trophyTitleIconUrl'])

        game_trophies_list = @client.request_game_trophy_list(
          token: @token, game_id: id, trophy_service_source: game.trophy_service_source
        )
        additional_trophies_info = @client.request_game_player_trophies(
          user_id: @player.user_id, token: @token, game_id: id,
          trophy_service_source: game.trophy_service_source
        )
        trophies_list = merge_trophies(game_trophies_list, additional_trophies_info)

        # TODO: find import (bulk_upload) in sequel and use it to query all trophies to db
        # TODO: It's called import for Christ sake. How didn't I find it before
        trophies_list.each do |trophy|
          game.add_trophy(Trophy.create(trophy_name: trophy['trophyName'],
                                        trophy_service_id: trophy['trophyId'],
                                        trophy_description: trophy['trophyDetail'],
                                        trophy_type: trophy['trophyType'],
                                        trophy_icon_url: trophy['trophyIconUrl'],
                                        trophy_earned_rate: trophy['trophyEarnedRate'],
                                        trophy_rare: trophy['trophyRare']))
        end
      end
    end

    private

    def prepare_game_title(game_title)
      game_title.gsub(/[\u2122\u00ae\n]/, ' ').gsub(/  /, ' ').strip
    end

    def merge_trophies(game_trophies, trophies_info)
      game_trophies.map do |trophy|
        trophy.merge(
          trophies_info.find { |trophy_info| trophy_info['trophyId'] == trophy['trophyId'] }
        )
      end
    end
  end
end
