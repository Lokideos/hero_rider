# frozen_string_literal: true

module RiderData
  class FindGameService
    prepend BasicService

    param :game_title
    option :client, default: proc { DataService::HttpClient.new }

    attr_reader :game_top

    def call
      @game_top = @client.game_top(@game_title[:game_title])

      valid?(@game_top) ? @game_top = @game_top[:body] : fail_t!(:not_found)
    end

    def valid?(game_top_result)
      game_top_result[:status] == 200
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.rider_data.find_game_service'))
    end
  end
end
