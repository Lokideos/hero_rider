# frozen_string_literal: true

module Chat
  module Command
    class PlayerDestroy
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
        result = ::Players::DestroyService.call(username)

        @message = result.success? ? success_message(result) : error_message(result)
      end

      private

      def success_message(result)
        [I18n.t(:success, scope: 'services.command_service.player_destroy',
                          name: result.player.telegram_username)]
      end

      def error_message(result)
        result.errors
      end
    end
  end
end
