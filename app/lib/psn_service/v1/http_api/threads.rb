# frozen_string_literal: true

module PsnService
  module V1
    module HttpApi
      module Threads
        THREADS_FIELDS = %w[threadMembers threadNameDetail threadThumbnailDetail threadProperty
                            latestMessageEventDetail latestTakedownEventDetail
                            newArrivalEventDetail].freeze

        MESSAGE_THREADS_FIELDS = %w[threadMembers threadNameDetail threadThumbnailDetail
                                    threadProperty latestTakedownEventDetail newArrivalEventDetail
                                    threadEvents].freeze

        def request_message_threads(token:, limit: 10, offset: 0)
          response = connection.get do |request|
            request.headers = threads_common_headers(token)
            request.params = threads_params(THREADS_FIELDS.join(','), limit, offset)
          end

          response.body['threads']
        end

        def request_messages_from_thread(thread_id:, token:, message_count: 10)
          endpoint = thread_id.to_s
          response = connection.get(endpoint) do |request|
            request.headers = threads_common_headers(token)
            request.params = thread_messages_params(message_count, MESSAGE_THREADS_FIELDS.join(','))
          end

          response.body['threadEvents']
        end

        def download_image_data(token:)
          response = connection.get do |request|
            request.headers = threads_common_headers(token)
          end

          response.body
        end

        def threads_common_headers(token)
          {
            'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) ' \
                  'AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
            'Authorization' => "Bearer #{token}"
          }
        end

        def thread_messages_params(message_count, fields)
          {
            'count': message_count,
            'fields': fields
          }
        end

        def threads_params(fields, limit, offset)
          {
            'fields': fields,
            'limit': limit,
            'offset': offset
          }
        end
      end
    end
  end
end
