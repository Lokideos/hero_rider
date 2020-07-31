# frozen_string_literal: true

module RiderData
  module Hunters
    class GetHuntersService
      prepend BasicService

      option :client, default: proc { DataService::HttpClient.new }

      attr_reader :hunters

      def call
        result = @client.request_hunters_data

        valid?(result) ? @hunters = result[:body] : fail_t!(:failure)
      end

      def valid?(result)
        result[:status] == 200
      end

      def fail_t!(key)
        fail!(I18n.t(key, scope: 'services.rider_data.hunters.get_hunters_service'))
      end
    end
  end
end
