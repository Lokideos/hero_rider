# frozen_string_literal: true

module Chat
  module Command
    class PlayerRename
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
        new_username = message[2]

        result = ::Players::RenameService.call(username, new_username)
        @message = result.success? ? success_message(username, new_username) : error_message(result)
      end

      private

      def success_message(username, new_username)
        [I18n.t(:success, scope: 'services.command_service.player_rename',
                          name: username,
                          new_name: new_username)]
      end

      def error_message(result)
        result.errors
      end
    end
  end
end
