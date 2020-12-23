# frozen_string_literal: true

module Psn
  class UpdateAccessTokenService
    prepend BasicService

    param :hunter
    option :client, default: proc { PsnService::V2::HttpClient.new }

    attr_reader :access_token

    def call
      access_token_response = @client.request_access_token(hunter: @hunter)
      return fail_t!(:failure) unless valid_response?(access_token_response)

      @access_token = access_token_response[:access_token]
      @hunter.store_access_token(@access_token)
    end

    private

    def valid_response?(response)
      response[:status] == 200
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.psn.update_access_token_service'))
    end
  end
end
