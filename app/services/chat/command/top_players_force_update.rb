# frozen_string_literal: true

module Chat
  module Command
    class TopPlayersForceUpdate
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(username)
        return unless result.success?

        Player.trophy_top_force_update
        @message = [I18n.t(:success, scope: 'services.command_service.top_players_force_update')]
      end
    end
  end
end
