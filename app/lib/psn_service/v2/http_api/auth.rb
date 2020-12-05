module PsnService
  module V2
    module HttpApi
      module Auth
        def request_access_token(hunter:)
          response = connection.post(Settings.psn.v2.auth.endpoint) do |request|
            request.headers = {
              'Content-Type' => 'application/x-www-form-urlencoded',
              'User-Agent' => 'com.sony.snei.np.android.sso.share.oauth.versa.USER_AGENT',
              'Authorization' => "Basic #{hunter.authorization_token}"
            }
            request.body = {
              'token_format': 'jwt',
              'grant_type': 'refresh_token',
              'scope': 'psn:mobile.v1 psn:clientapp',
              'refresh_token': hunter.refresh_token,
            }
          end

          { status: response.status, access_token: response.body['access_token'] }
        end
      end
    end
  end
end
