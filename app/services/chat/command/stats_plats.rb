# frozen_string_literal: true

module Chat
  module Command
    class StatsPlats
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        text = @command[@message_type]['text']
        player_name = text.include?('@') ? text.split(' ')[1][1..] : text.split(' ')[1]
        result = ::Players::FindPlayerService.call(player_name)
        return @message = ['Игрок не найден'] if result.failure?

        trophy_account = result.player.trophy_account
        telegram_name = result.player.telegram_username
        unique_platinum_games = Player.uniq_plat_games(trophy_account)

        message = ["<b>Уникальные платины игрока #{trophy_account} (@#{telegram_name})</b>"]
        unique_platinum_games.each do |game|
          message << game
        end
        if unique_platinum_games.empty?
          message = ["У игрока #{trophy_account} (@#{telegram_name}) нет уникальных платин"]
        end

        @message = [message.join("\n")]
      end
    end
  end
end
