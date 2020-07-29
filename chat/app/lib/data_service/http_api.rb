# frozen_string_literal: true

module DataService
  module HttpApi
    def game_top(game_title)
      response = connection.get('game_top') do |request|
        request.body = { game_title: game_title }
      end

      { status: response.status, body: response.body }
    end

    def relevant_games(game_title, player_name)
      response = connection.get('relevant_games') do |request|
        request.body = { game_title: game_title, player_name: player_name }
      end

      { status: response.status, body: response.body }
    end

    def game_from_cache(game_index, player_name)
      response = connection.get('game_from_cache') do |request|
        request.body = { game_index: game_index, player_name: player_name }
      end

      { status: response.status, body: response.body }
    end

    def activate_hunter(hunter_name)
      response = connection.post('activate_hunter') do |request|
        request.body = { hunter_name: hunter_name }
      end

      { status: response.status, body: response.body }
    end

    def deactivate_hunter(hunter_name)
      response = connection.post('deactivate_hunter') do |request|
        request.body = { hunter_name: hunter_name }
      end

      { status: response.status, body: response.body }
    end

    def request_hunter_data(hunter_name)
      response = connection.get('hunter') do |request|
        request.body = { hunter_name: hunter_name }
      end

      { status: response.status, body: response.body }
    end

    def authenticate(telegram_username)
      response = connection.post('authenticate') do |request|
        request.body = { username: telegram_username }
      end

      { status: response.status, body: response.body }
    end

    def admin_authenticate(telegram_username)
      response = connection.post('admin_authenticate') do |request|
        request.body = { username: telegram_username }
      end

      { status: response.status, body: response.body }
    end
  end
end
