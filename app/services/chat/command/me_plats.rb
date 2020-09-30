# frozen_string_literal: true

module Chat
  module Command
    class MePlats
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        result = ::Players::FindPlayerService.call(@command['message']['from']['username'])
        return if result.failure?

        trophy_account = result.player.trophy_account
        telegram_name = result.player.telegram_username
        unique_platinum_games = Player.uniq_plat_games(trophy_account)

        message = ["<b>Уникальные платины игрока #{trophy_account} (@#{telegram_name})</b>"]
        unique_platinum_games.each do |game|
          message << game
        end
        message = ['У вас нет уникальных платин'] if unique_platinum_games.empty?

        @message = [message.join("\n")]
      end
    end
  end
end
