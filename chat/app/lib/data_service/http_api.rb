# frozen_string_literal: true

module DataService
  module HttpApi
    def game_top(game_title)
      response = connection.get('game_top') do |request|
        request.body = { game_title: game_title }
      end

      { status: response.status, body: response.body }
    end

    def authenticate(telegram_username)
      response = connection.post('authenticate') do |request|
        request.body = { username: telegram_username }
      end

      { status: response.status, body: response.body }
    end
  end
end
