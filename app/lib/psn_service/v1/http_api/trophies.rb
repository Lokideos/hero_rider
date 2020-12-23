# frozen_string_literal: true

module PsnService
  module V1
    module HttpApi
      module Trophies
        EXTENDED_TROPHY_FIELDS = %w[trophyRare trophyEarnedRate trophySmallIconUrl groupId].freeze

        def request_trophy_list(player_name:, token:, offset: 0, limit: 10)
          initial_load = RedisDb.redis.get("holy_rider:watcher:players:initial_load:#{player_name}")
          game_progress_update =
            RedisDb.redis.get("holy_rider:watcher:players:progress_update:#{player_name}")
          limit = 128 if initial_load || game_progress_update
          response = connection.get do |request|
            request.headers = trophy_common_headers(token)
            request.params = trophy_list_params(offset, limit, player_name)
          end
          return response.body unless initial_load

          response_body = response.body

          until (response_body['totalResults'] - limit - offset).negative?
            offset += limit
            next_response = connection.get do |request|
              request.headers = trophy_common_headers(token)
              request.params = trophy_list_params(offset, limit, player_name)
            end
            response_body['trophyTitles'] += next_response.body['trophyTitles']
          end

          response_body
        end

        def request_game_trophy_list(player_name:, token:, game_id:, extended: false)
          endpoint = game_id + Settings.psn.v1.game_trophies.endpoint
          fields = extended ? "@default,#{EXTENDED_TROPHY_FIELDS.join(',')}" : '@default'

          response = connection.get(endpoint) do |request|
            request.headers = trophy_common_headers(token)
            request.params = game_trophy_list_params(fields, player_name)
          end

          if response.status == 429
            # TODO: use Fibonacci sequence for 429 status processing
            sleep_increment = 0
            until response.status != 429
              p 'Watcher: gateway timeout - too many requests'
              sleep_increment += 1
              sleep(sleep_increment)
              response = connection.get(endpoint) do |request|
                request.headers = trophy_common_headers(token)
                request.params = game_trophy_list_params(fields, player_name)
              end
            end
          end

          response.body['trophies']
        end

        def trophy_common_headers(token)
          {
            'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                  'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
            'Authorization' => "Bearer #{token}"
          }
        end

        def game_trophy_list_params(fields, player_name)
          {
            'fields': fields,
            'visibleType': 1,
            'npLanguage': 'en',
            'comparedUser': player_name
          }
        end

        def trophy_list_params(offset, limit, player_name)
          {
            'fields': '@default',
            'npLanguage': 'en',
            'iconSize': 'm',
            'platform': 'PS3,PSVITA,PS4',
            'offset': offset,
            'limit': limit,
            'comparedUser': player_name
          }
        end
      end
    end
  end
end
