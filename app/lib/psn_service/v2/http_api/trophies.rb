# frozen_string_literal: true

module PsnService
  module V2
    module HttpApi
      module Trophies
        def request_trophy_list(user_id:, player_name:, token:, limit: 100, offset: 0)
          endpoint = "#{Settings.psn.v2.trophies.endpoints.user_trophies}/#{user_id}/trophyTitles"

          initial_load = RedisDb.redis.get("holy_rider:watcher:players:initial_load:#{player_name}")
          response = connection.get(endpoint) do |request|
            request.headers = trophy_common_headers(token)
            request.params = trophy_list_params(limit, offset)
          end
          if response.status == 403 && response.body.dig('error', 'code') == 2240526
            return { status: 403, body: 'Access Denied'}
          end

          return response.body unless initial_load

          response_body = response.body

          until (response_body['totalItemCount'] - limit - offset).negative?
            offset += limit
            next_response = connection.get(endpoint) do |request|
              request.headers = trophy_common_headers(token)
              request.params = trophy_list_params(limit, offset)
            end
            response_body['trophyTitles'] += next_response.body['trophyTitles']
          end

          response_body
        end

        def request_game_trophy_list(token:, game_id:, trophy_service_source:,
                                     limit: 100, offset: 0)
          endpoint = "#{Settings.psn.v2.trophies.endpoints.game_trophies}/" \
                      "#{game_id}/trophyGroups/default/trophies"

          response = connection.get(endpoint) do |request|
            request.headers = trophy_common_headers(token)
            request.params = game_trophy_list_params(limit, offset, trophy_service_source)
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
                request.params = game_trophy_list_params(limit, offset, trophy_service_source)
              end
            end
          end

          response.body['trophies']
        end

        def request_game_player_trophies(user_id:, token:, game_id:, trophy_service_source:,
                                         limit: 100, offset: 0)
          endpoint = "#{Settings.psn.v2.trophies.endpoints.user_trophies}/#{user_id}/" \
                      "npCommunicationIds/#{game_id}/trophyGroups/default/trophies"

          response = connection.get(endpoint) do |request|
            request.headers = trophy_common_headers(token)
            request.params = game_trophy_list_params(limit, offset, trophy_service_source)
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
                request.params = game_trophy_list_params(limit, offset, trophy_service_source)
              end
            end
          end

          response.body['trophies']
        end

        def trophy_common_headers(token)
          {
            'Authorization' => "Bearer #{token}",
            'Accept-Language' => 'en-GB',
            'User-Agent' => 'okhttp/13.4.3'
          }
        end

        def game_trophy_list_params(limit, offset, trophy_service_source)
          {
            'limit': limit,
            'npServiceName': trophy_service_source,
            'offset': offset
          }
        end

        def trophy_list_params(limit, offset)
          {
            'limit': limit,
            'offset': offset
          }
        end
      end
    end
  end
end
