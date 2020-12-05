# frozen_string_literal: true

module Chat
  module Command
    class PlayerAdd
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
        unless username.present?
          @message = [I18n.t(:player_not_provided, scope: 'services.command_service.player_add')]
          return
        end

        result = ::Players::CreateService.call(username, trophy_account)
        if trophy_account.present? && result.success?
          ::Profile::FriendRequestService.call(TrophyHunter.first, trophy_account)
        end
        @message = result.success? ? success_response(result.player) : failure_response
      end

      private

      def success_response(player)
        if player.trophy_account.present?
          return [I18n.t(:success_with_trophies,
                         scope: 'services.command_service.player_add',
                         username: player.telegram_username,
                         trophy_account: player.trophy_account)]
        end

        [I18n.t(:success, scope: 'services.command_service.player_add',
                          username: player.telegram_username)]
      end

      def failure_response
        [I18n.t(:failure, scope: 'services.command_service.player_add')]
      end
    end
  end
end
