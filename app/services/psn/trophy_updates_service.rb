# frozen_string_literal: true

module Psn
  class TrophyUpdatesService
    prepend BasicService

    option :player_name
    option :user_id
    option :token
    option :client, default: proc {
      PsnService::V2::HttpClient.new(url: Settings.psn.v2.trophies.url)
    }

    attr_reader :result

    def call
      @result = @client.request_trophy_list(user_id: @user_id, player_name: @player_name,
                                            token: @token)
    end
  end
end
