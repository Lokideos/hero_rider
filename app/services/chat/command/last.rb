# frozen_string_literal: true

module Chat
  module Command
    class Last
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        result = ::Games::LastGameService.call
        if result.failure?
          @message = ['Игра не найдена']
          return
        end

        top = result.game_top
        title = "<a href='#{top['game']['icon_url']}'>" \
                "#{top['game']['title']} #{top['game']['platform']}</a>"
        game_top = Chat::GameTopService.call(top['progresses']).game_top

        @message = [title, game_top]
      end
    end
  end
end
