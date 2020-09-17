# frozen_string_literal: true

module Watcher
  class LinkGamesService
    prepend BasicService

    option :player_name
    option :updates
    option :player, default: proc { Player.find(trophy_account: @player_name) }

    def call
      trophy_service_ids = @updates['trophyTitles'].map { |game| game['npCommunicationId'] }
      owned_game_ids = @player.games.map(&:trophy_service_id)
      games_to_link_ids = (trophy_service_ids - owned_game_ids)
      # TODO: fix possible n+1 issue
      games_to_link_ids.each do |id|
        @player.add_game(Game.find(trophy_service_id: id))
      end
    end
  end
end
