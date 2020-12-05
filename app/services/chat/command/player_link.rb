# frozen_string_literal: true

module Chat
  module Command
    class PlayerLink
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

        result = ::Players::LinkService.call(username, trophy_account)
        ::Profile::FriendRequestService.call(TrophyHunter.first, trophy_account, notify_user: true)
        @message = result.success? ? success_message(result) : error_message(result)
      end

      private

      def success_message(result)
        [I18n.t(:success, scope: 'services.command_service.player_link',
                          name: result.player.telegram_username,
                          trophy_account: result.player.trophy_account)]
      end

      def error_message(result)
        result.errors
      end
    end
  end
end
