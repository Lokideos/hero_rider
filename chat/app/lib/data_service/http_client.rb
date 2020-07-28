# frozen_string_literal: true

module DataService
  class HttpClient
    extend Dry::Initializer[undefined: false]
    include HttpApi

    option :url, default: proc { Settings.services.data.endpoint }
    option :connection, default: proc { build_connection }

    private

    def build_connection
      Faraday.new(@url) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter :typhoeus
      end
    end
  end
end
