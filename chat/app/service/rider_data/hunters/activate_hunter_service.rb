# frozen_string_literal: true

module RiderData
  module Hunters
    class ActivateHunterService
      prepend BasicService

      param :hunter_name
      option :client, default: proc { DataService::HttpClient.new }

      def call
        result = @client.activate_hunter(@hunter_name)

        valid?(result) ? result : fail_t!(:failure)
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
