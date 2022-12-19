module PsnService
  module V2
    module HttpApi
      module Auth
        def request_access_token(hunter:)
          response = connection.post(Settings.psn.v2.auth.endpoints.token) do |request|
            request.headers = {
              'Content-Type' => 'application/x-www-form-urlencoded',
              'User-Agent' => 'com.sony.snei.np.android.sso.share.oauth.versa.USER_AGENT',
              'Authorization' => "Basic #{hunter.authorization_token}"
            }
            request.body = {
              'token_format': 'jwt',
              'grant_type': 'refresh_token',
              'scope': 'psn:mobile.v2.core psn:clientapp',
              'refresh_token': hunter.refresh_token,
            }
          end

          { status: response.status, access_token: response.body['access_token'] }
        end

        def request_authorization_code(hunter:, sso_cookie:)
          response = connection.get(Settings.psn.v2.auth.endpoints.code) do |request|
            request.headers = {
              'Content-Type' => 'application/x-www-form-urlencoded',
              'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                 'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
              'Cookie' => "npsso=#{sso_cookie}"
            }
            request.params = {
              'access_type': 'offline',
              'app_context': hunter.app_context,
              'auth_ver': 'v3',
              'cid': '60351282-8C5F-4D5E-9033-E48FEA973E11',
              'client_id': hunter.client_id,
              'darkmode': 'true',
              'device_base_font_size': 10,
              'device_profile': 'mobile',
              'duid': hunter.duid,
              'elements_visibility': 'no_aclink',
              'extraQueryParams': '{PlatformPrivacyWs1 = minimal;}',
              'no_captcha': 'true',
              'redirect_uri': 'com.scee.psxandroid.scecompcall://redirect',
              'response_type': 'code',
              'scope': 'psn:mobile.v2.core psn:clientapp',
              'service_entity': 'urn:service-entity:psn',
              'smcid': 'psapp:settings-entrance',
              'support_scheme': 'sneiprls',
              'token_format': 'jwt',
              'ui': 'pr'
            }
          end
          code = response.headers['Location']&.match(/(code=.*&)/)[1][5..-2]

          { status: response.status, authorization_code: code }
        end

        def request_refresh_token(hunter:, authorization_code:, sso_cookie:)
          response = connection.post(Settings.psn.v2.auth.endpoints.token) do |request|
            request.headers = {
              'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                 'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
              'Cookie' => "npsso=#{sso_cookie}",
              'Authorization' => "Basic #{hunter.authorization_token}"
            }
            request.body = {
              'smcid': 'psapp%3Asettings-entrance',
              'access_type': 'offline',
              'code': authorization_code,
              'service_logo': 'ps',
              'ui': 'pr',
              'elements_visibility': 'no_aclink',
              'redirect_uri': 'com.scee.psxandroid.scecompcall://redirect',
              'support_scheme': 'sneiprls',
              'grant_type': 'authorization_code',
              'darkmode': 'true',
              'device_base_font_size': 10,
              'device_profile': 'mobile',
              'app_context': hunter.app_context,
              'extraQueryParams': '{PlatformPrivacyWs1 = minimal;}',
              'token_format': 'jwt'
            }
          end

          { status: response.status, refresh_token: response.body['refresh_token'] }
        end
      end
    end
  end
end
