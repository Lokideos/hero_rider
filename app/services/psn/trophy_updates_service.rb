# frozen_string_literal: true

module Psn
  class TrophyUpdatesService
    prepend BasicService

    option :player_name
    option :token
    option :client, default: proc {
      PsnService::V1::HttpClient.new(url: Settings.psn.v1.trophies.url)
    }

    attr_reader :result

    def call
      @result = @client.request_trophy_list(player_name: @player_name, token: @token)
    end
  end
end
