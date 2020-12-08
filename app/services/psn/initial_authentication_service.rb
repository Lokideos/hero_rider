# frozen_string_literal: true

module Psn
  class InitialAuthenticationService
    prepend BasicService

    param :hunter
    param :sso_cookie
    option :client, default: proc { PsnService::V2::HttpClient.new }

    def call
      auth_code_response = @client.request_authorization_code(hunter: @hunter,
                                                              sso_cookie: @sso_cookie)
      return fail_t!(:auth_code_failure) unless valid_grant_code?(auth_code_response)

      auth_code = auth_code_response[:authorization_code]
      refresh_token_response = @client.request_refresh_token(hunter: @hunter,
                                                             authorization_code: auth_code,
                                                             sso_cookie: @sso_cookie)
      return fail_t!(:refresh_token_failure) unless valid_response?(refresh_token_response)

      refresh_token = refresh_token_response[:refresh_token]
      @hunter.update(refresh_token: refresh_token)
      Psn::UpdateAccessTokenService.call(@hunter)
    end

    private

    def valid_grant_code?(response)
      response[:status] == 302 && response[:authorization_code].present?
    end

    def valid_response?(response)
      response[:status] == 200
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.psn.initial_authentication_service'))
    end
  end
end
