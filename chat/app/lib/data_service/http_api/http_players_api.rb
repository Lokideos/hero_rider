# frozen_string_literal: true

module DataService
  module HttpApi
    module HttpPlayersApi
      def authenticate(telegram_username)
        response = connection.post('players/authenticate') do |request|
          request.body = { username: telegram_username }
        end

        { status: response.status, body: response.body }
      end

      def admin_authenticate(telegram_username)
        response = connection.post('players/admin_authenticate') do |request|
          request.body = { username: telegram_username }
        end

        { status: response.status, body: response.body }
      end

      def player_info(username)
        response = connection.get('players/info') do |request|
          request.body = { username: username }
        end

        { status: response.status, body: response.body }
      end
    end
  end
end
