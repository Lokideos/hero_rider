# frozen_string_literal: true

module Chat
  module Command
    class PlayerWatchOff
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(username)
        return unless result.success?

        player_name = @command[@message_type]['text'].split(' ')[1]
        result = ::Players::WatchOffService.call(player_name)
        @message = result.success? ? success_message(result) : error_message(result)
      end

      private

      def success_message(result)
        [I18n.t(:success, scope: 'services.command_service.player_watch_off',
                          name: result.player.telegram_username)]
      end

      def error_message(result)
        result.errors
      end
    end
  end
end
