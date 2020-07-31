# frozen_string_literal: true

module Chat
  module Command
    class TopGamesForceUpdate
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(username)
        return unless result.success?

        Game.update_all_progress_caches
        @message = [I18n.t(:success, scope: 'services.command_service.top_games_force_update')]
      end
    end
  end
end
