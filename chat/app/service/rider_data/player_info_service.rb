# frozen_string_literal: true

module RiderData
  class PlayerInfoService
    prepend BasicService

    param :username
    option :client, default: proc { DataService::HttpClient.new }

    attr_reader :profile

    def call
      result = @client.player_info(@username)

      valid?(result) ? @profile = result[:body] : fail_t!(:not_found)
    end

    def valid?(result)
      result[:status] == 200
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.rider_data.player_info_service'))
    end
  end
end
