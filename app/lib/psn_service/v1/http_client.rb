# frozen_string_literal: true

module PsnService
  module V1
    class HttpClient
      extend Dry::Initializer[undefined: false]
      include HttpApi

      option :url, default: proc { Settings.psn.v1.auth.url }
      option :connection, default: proc { build_connection }

      private

      def build_connection
        Faraday.new(@url) do |conn|
          conn.request :url_encoded
          conn.response :json, content_type: /\bjson$/
          conn.adapter :typhoeus
        end
      end
    end
  end
end
