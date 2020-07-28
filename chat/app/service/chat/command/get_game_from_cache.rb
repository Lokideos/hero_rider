# frozen_string_literal: true

module Chat
  module Command
    class GetGameFromCache
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        game_index = @command[@message_type]['text'].split(' ')[0].split('@')[0][1..]
        player_name = @command['message']['from']['username']
        result = RiderData::RetrieveGameFromCacheService.call(game_index, player_name)
        return if result.failure?

        cached_top = result.cached_game_top

        title = "<a href='#{cached_top['game']['icon_url']}'>" \
                "#{cached_top['game']['title']} #{cached_top['game']['platform']}</a>"
        game_top = Chat::GameTopService.call(top: cached_top['progresses']).game_top

        @message = [title, game_top]
      end
    end
  end
end
