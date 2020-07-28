# frozen_string_literal: true

module RiderData
  class RetrieveGameFromCacheService
    prepend BasicService

    param :game_index
    param :player_name
    option :client, default: proc { DataService::HttpClient.new }

    attr_reader :cached_game_top

    def call
      result = @client.game_from_cache(@player_name, @game_index)

      valid?(result) ? @cached_game_top = result[:body] : fail_t!(:not_found)
    end

    def valid?(result)
      result[:status] == 200
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.rider_data.retrieve_game_from_cache_service'))
    end
  end
end
