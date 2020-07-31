# frozen_string_literal: true

module PsnService
  module HttpApi
    def request_grant_code(hunter:, sso_cookie:)
      response = connection.get('authorize') do |request|
        request.headers = {
          'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
          'Cookie' => "npsso=#{sso_cookie}"
        }
        request.params = {
          'state': hunter.state,
          'duid': hunter.duid,
          'app_context': hunter.app_context,
          'client_id': hunter.client_id,
          'scope': hunter.scope,
          'response_type': 'code'
        }
      end

      { status: response.status, grant_code: response.headers['X-NP-GRANT-CODE'] }
    end

    def request_refresh_token(hunter:, grant_code:)
      response = connection.post('token') do |request|
        request.headers = {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
        }
        request.body = {
          'app_context': hunter.app_context,
          'client_id': hunter.client_id,
          'client_secret': hunter.client_secret,
          'code': grant_code,
          'duid': hunter.duid,
          'grant_type': 'authorization_code',
          'scope': hunter.scope
        }
      end

      { status: response.status, refresh_token: response.body['refresh_token'] }
    end

    def request_access_token(hunter:)
      response = connection.post('token') do |request|
        request.headers = {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
        }
        request.body = {
          'app_context': hunter.app_context,
          'client_id': hunter.client_id,
          'client_secret': hunter.client_secret,
          'refresh_token': hunter.refresh_token,
          'duid': hunter.duid,
          'grant_type': 'refresh_token',
          'scope': hunter.scope
        }
      end

      { status: response.status, access_token: response.body['access_token'] }
    end
  end
end
