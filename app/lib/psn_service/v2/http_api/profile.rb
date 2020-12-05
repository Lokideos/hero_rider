# frozen_string_literal: true

module PsnService
  module V2
    module HttpApi
      module Profile
        def request_user_ids(token:, user_id:, limit: 100, offset: 0)
          endpoint = "#{Settings.psn.v2.profile.endpoints.user_ids}/#{user_id}/friends"

          response = connection.get(endpoint) do |request|
            request.headers = profile_common_headers(token)
            request.params = user_ids_list_params(limit, offset)
          end

          response.body['friends']
        end

        def request_users_info(token:, account_ids:)
          endpoint = Settings.psn.v2.profile.endpoints.profile_info

          response = connection.get(endpoint) do |request|
            request.headers = profile_common_headers(token)
            request.params = profile_list_params(account_ids)
          end

          response.body['profiles'].map { |profile| profile['onlineId'] }
        end

        private

        def profile_common_headers(token)
          {
            'Authorization' => "Bearer #{token}",
            'Accept-Language' => 'en-GB',
            'User-Agent' => 'okhttp/13.4.3'
          }
        end

        def profile_list_params(account_ids)
          {
            'accountIds': account_ids.join(',')
          }
        end

        def user_ids_list_params(limit, offset)
          {
            'limit': limit,
            'offset': offset,
            'order': 'onlineId'
          }
        end
      end
    end
  end
end
