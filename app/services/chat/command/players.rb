# frozen_string_literal: true

module Chat
  module Command
    class Players
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(telegram_username)
        return unless result.success?

        players = Player.order(:created_at)
        message = [
          'Список игроков:', '  Ник в Телеграм Аккаунт для трофеев Отслеживание статуса'
        ]
        players.each_with_index do |player, index|
          message << "#{index + 1}. #{player.telegram_username} #{player.trophy_account} " \
                     "#{player.on_watch?}"
        end

        @message = [message.join("\n")]
      end
    end
  end
end
