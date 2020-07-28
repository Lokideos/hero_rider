# frozen_string_literal: true

module RiderData
  class RelevantGamesService
    prepend BasicService

    param :game_title
    param :player_name
    option :client, default: proc { DataService::HttpClient.new }

    attr_reader :games_list

    def call
      result = @client.relevant_games(@game_title, @player_name)

      valid?(result) ? @games_list = result[:body] : fail_t!(:not_found)
    end

    def valid?(result)
      result[:status] == 200
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.rider_data.relevant_games_service'))
    end
  end
end
