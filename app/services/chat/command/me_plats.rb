# frozen_string_literal: true

module Chat
  module Command
    class Me
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        result = ::Players::FindPlayerService.call(@command['message']['from']['username'])
        return if result.failure?

        trophy_account = result.player.trophy_account
        telegram_name = result.player.telegram_username

        message = ["<b>Уникальные платины игрока #{trophy_account} (@#{telegram_name})</b>"]

        @message = [message.join("\n")]
      end
    end
  end
end
