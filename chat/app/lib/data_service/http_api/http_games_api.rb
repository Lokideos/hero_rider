# frozen_string_literal: true

module DataService
  module HttpApi
    module HttpGamesApi
      def game_top(game_title)
        response = connection.get('games/game_top') do |request|
          request.body = { game_title: game_title }
        end

        { status: response.status, body: response.body }
      end

      def relevant_games(game_title, player_name)
        response = connection.get('games/relevant_games') do |request|
          request.body = { game_title: game_title, player_name: player_name }
        end

        { status: response.status, body: response.body }
      end

      def game_from_cache(game_index, player_name)
        response = connection.get('games/game_from_cache') do |request|
          request.body = { game_index: game_index, player_name: player_name }
        end

        { status: response.status, body: response.body }
      end
    end
  end
end
