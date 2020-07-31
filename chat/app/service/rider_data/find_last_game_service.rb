# frozen_string_literal: true

module RiderData
  class FindLastGameService
    prepend BasicService

    option :client, default: proc { DataService::HttpClient.new }

    attr_reader :game_top

    def call
      game_top_result = @client.last_game

      valid?(game_top_result) ? @game_top = game_top_result[:body] : fail_t!(:failure)
    end

    def valid?(game_top_result)
      game_top_result[:status] == 200
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.rider_data.find_last_game_service'))
    end
  end
end
