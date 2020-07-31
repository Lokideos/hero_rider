# frozen_string_literal: true

module RiderData
  module Hunters
    class GetHunterService
      prepend BasicService

      param :hunter_name
      option :client, default: proc { DataService::HttpClient.new }

      attr_reader :hunter

      def call
        result = @client.request_hunter_data(@hunter_name)

        valid?(result) ? @hunter = result[:body] : fail_t!(:failure)
      end

      def valid?(result)
        result[:status] == 200
      end

      def fail_t!(key)
        fail!(I18n.t(key, scope: 'services.rider_data.hunters.activate_hunter_service'))
      end
    end
  end
end
