# frozen_string_literal: true

module RiderData
  module Players
    class AddPlayerService
      prepend BasicService

      param :username
      param :trophy_account, default: nil
      option :client, default: proc { DataService::HttpClient.new }

      attr_reader :player

      def call
        result = @client.create_player(@username, trophy_account: @trophy_account)

        valid?(result) ? @player = result[:body] : fail_t!(:failure, @username)
      end

      def valid?(result)
        result[:status] == 201
      end

      def fail_t!(key, name)
        fail!(I18n.t(key, scope: 'services.rider_data.players.add_player_service', name: name))
      end
    end
  end
end
