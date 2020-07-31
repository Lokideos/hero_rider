# frozen_string_literal: true

module Psn
  class InitialAuthenticationService
    prepend BasicService

    param :hunter
    param :sso_cookie
    option :client, default: proc { PsnService::HttpClient.new }

    def call
      grant_code_response = @client.request_grant_code(hunter: @hunter, sso_cookie: @sso_cookie)
      return fail_t!(:grant_code_failure) unless valid_grant_code?(grant_code_response)

      grant_code = grant_code_response[:grant_code]
      refresh_token_response = @client.request_refresh_token(hunter: @hunter,
                                                             grant_code: grant_code)
      return fail_t!(:refresh_token_failure) unless valid_response?(refresh_token_response)

      refresh_token = refresh_token_response[:refresh_token]
      @hunter.update(refresh_token: refresh_token)
      Psn::UpdateAccessTokenService.call(@hunter)
    end

    private

    def valid_grant_code?(grant_code_response)
      grant_code_response[:status] == 302 && grant_code_response[:grant_code].present?
    end

    def valid_response?(response)
      response[:status] == 200
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.psn.initial_authentication_service'))
    end
  end
end
