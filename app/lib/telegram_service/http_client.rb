# frozen_string_literal: true

module TelegramService
  class HttpClient
    extend Dry::Initializer[undefined: false]
    include HttpApi

    option :url, default: proc { Settings.telegram.endpoint + "#{Settings.telegram.bot_token}/" }
    option :connection, default: proc { build_connection }

    private

    def build_connection
      Faraday.new(@url) do |conn|
        conn.request :json
        conn.request :multipart
        conn.response :json, content_type: /\bjson$/
        conn.adapter :typhoeus
      end
    end
  end
end
