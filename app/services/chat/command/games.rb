# frozen_string_literal: true

module Chat
  module Command
    class Games
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        game_title = @command[@message_type]['text'].split(' ')[1..].join(' ')
        player_name = @command[@message_type]['from']['username']
        result = ::Games::RelevantGamesService.call(game_title, player_name)
        if result.failure?
          @message = [I18n.t(:not_found, scope: 'services.command_service.games')]
          return
        end

        games_list = result.games_list
        player_username = @command[@message_type]['from']['username']
        message = []
        message << "@#{player_username}"
        message << '<b>Найденные игры:</b>'
        games_list.each_with_index do |game, index|
          message << "/#{index + 1} <b>#{game}</b>"
        end

        @message = [message.join("\n")]
      end
    end
  end
  end
