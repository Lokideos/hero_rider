# frozen_string_literal: true

module Chat
  module Command
    class PlayerBefriendAll
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(telegram_username)
        return unless result.success?

        message = @command[@message_type]['text'].split(' ')
        username = message[1]
        trophy_account = message[2]

        result = ::Players::BefriendAllService.call(username, trophy_account)
        @message = result.success? ? success_message : error_message(result)
      end

      private

      def success_message
        [I18n.t(:success, scope: 'services.command_service.player_befriend_all')]
      end

      def error_message(result)
        result.errors
      end
    end
  end
end
