# frozen_string_literal: true

module PsnService
  module V1
    module HttpApi
      module Profile
        def request_trophy_summary(player_name:, token:)
          endpoint = player_name + Settings.psn.profile.endpoint
          response = connection.get(endpoint) do |request|
            request.headers = profile_common_headers(token)
            request.params = trophy_summary_params(player_name)
          end

          if response.status == 429

            sleep_increment = 0
            until response.status != 429
              p 'Watcher: gateway timeout - too many requests'
              # TODO: use Fibonacci sequence for 429 status processing
              sleep_increment += 1
              sleep(sleep_increment)

              response = connection.get(endpoint) do |request|
                request.headers = profile_common_headers(token)
                request.params = trophy_summary_params(player_name)
              end
            end
          end

          response.body['profile']['trophySummary']
        end

        def trophy_summary_params(player_name)
          {
            'fields': 'trophySummary(@default,progress,earnedTrophies)',
            'visibleType': 1,
            'npLanguage': 'en',
            'comparedUser': player_name
          }
        end

        def profile_common_headers(token)
          {
            'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                  'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
            'Authorization' => "Bearer #{token}"
          }
        end
      end
    end
  end
end
