# frozen_string_literal: true

module PsnService
  module V2
    module HttpApi
      module Profile
        def search_for_user_id(token:, trophy_account:, country: 'ru', language: 'ru')
          endpoint = Settings.psn.v2.profile.endpoints.search

          response = connection.post(endpoint) do |request|
            request.headers = search_for_user_id_headers(token)
            request.body = Oj.dump(
              search_for_user_id_body(trophy_account, country, language), {mode: :compat}
            )
          end

          response.body['domainResponses'].first['results'].first['socialMetadata']['accountId']
        end

        def request_user_ids(token:, user_id:, limit: 100, offset: 0)
          endpoint = "#{Settings.psn.v2.profile.endpoints.user_ids}/#{user_id}/friends"

          response = connection.get(endpoint) do |request|
            request.headers = profile_common_headers(token)
            request.params = user_ids_list_params(limit, offset)
          end

          if response.status == 429
            # TODO: use Fibonacci sequence for 429 status processing
            sleep_increment = 0
            until response.status != 429
              p 'Watcher: gateway timeout - too many requests'
              sleep_increment += 1
              sleep(sleep_increment)
              response = connection.get(endpoint) do |request|
                request.headers = profile_common_headers(token)
                request.params = user_ids_list_params(limit, offset)
              end
            end
          end

          response.body['friends']
        end

        def add_friend(token:, user_id:)
          endpoint = "#{Settings.psn.v2.profile.endpoints.friends}/#{user_id}"

          response = connection.post(endpoint) do |request|
            request.headers = add_friend_headers(token)
          end

          { status: response.status }
        end

        def delete_friend(token:, user_id:)
          endpoint = "#{Settings.psn.v2.profile.endpoints.friends}/#{user_id}"

          response = connection.delete(endpoint) do |request|
            request.headers = profile_common_headers(token)
          end

          { status: response.status }
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

        def search_for_user_id_headers(token)
          {
            'Authorization' => "Bearer #{token}",
            'Accept-Language' => 'ru-RU',
            'Accept' => 'application/json',
            'User-Agent' => 'okhttp/13.4.3',
            'Content-Type' => 'application/json'
          }
        end

        def add_friend_headers(token)
          {
            'Authorization' => "Bearer #{token}",
            'Accept-Language' => 'ru-RU',
            'Accept' => 'application/json',
            'User-Agent' => 'okhttp/13.4.3',
            'Content-Type' => 'application/json; charset=utf-8'
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

        def search_for_user_id_body(trophy_account, country, language)
          {
            'searchTerm': trophy_account,
            'domainRequests': [
              {
                'domain': 'SocialAllAccounts',
                'pagination': {
                  'cursor': '',
                  'pageSize': 20
                }
              }
            ],
            'countryCode': country,
            'languageCode': language,
            'age': 36
          }
        end
      end
    end
  end
end
