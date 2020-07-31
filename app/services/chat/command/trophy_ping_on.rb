# frozen_string_literal: true

module Chat
  module Command
    class TrophyPingOn
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        player_name = @command['message']['from']['username']
        result = ::Players::TrophyPingOnService.call(player_name)
        @message = result.success? ? success_message : error_message(result)
      end

      private

      def success_message
        [I18n.t(:success, scope: 'services.command_service.trophy_ping_on')]
      end

      def error_message(result)
        result.errors
      end
    end
  end
end
