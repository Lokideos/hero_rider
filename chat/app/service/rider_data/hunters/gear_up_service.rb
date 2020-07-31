# frozen_string_literal: true

module RiderData
  module Hunters
    class GearUpService
      prepend BasicService

      param :hunter_name
      param :sso_cookie
      option :client, default: proc { DataService::HttpClient.new }

      attr_reader :hunter

      def call
        result = @client.authenticate_hunter(@hunter_name, @sso_cookie)

        valid?(result) ? @hunter = result[:body] : fail_t!(:failure)
      end

      def valid?(result)
        result[:status] == 200
      end

      def fail_t!(key)
        fail!(I18n.t(key, scope: 'services.rider_data.hunters.gear_up_service', name: @hunter_name))
      end
    end
  end
end
