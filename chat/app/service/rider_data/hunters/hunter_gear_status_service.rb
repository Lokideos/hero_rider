# frozen_string_literal: true

module RiderData
  module Hunters
    class HunterGearStatusService
      prepend BasicService

      param :hunter_name
      option :client, default: proc { DataService::HttpClient.new }

      attr_reader :hunter

      def call
        result = @client.hunter_gear_status(@hunter_name)

        valid?(result) ? @hunter = result[:body] : fail!(result_errors(result))
      end

      def valid?(result)
        result[:status] == 200
      end

      def result_errors(result)
        result[:body]['errors'].flat_map(&:values)
      end
    end
  end
end
