# frozen_string_literal: true

module Chat
  module Command
    # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
    class SetResponsibleForRepairs
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(telegram_username)
        return unless result.success?

        message = @command[@message_type]['text'].split(' ')
        username = message[1]
        unless username.present?
          @message = [I18n.t(:player_not_provided, scope: 'services.command_service.set_responsible_for_repairs')]
          return
        end

        result = ::ResponsibleForRepairs::CreateService.call(username)

        @message = result.success? ? success_response(result.responsible_for_repair) : failure_response
      end

      private

      def success_response(responsible_for_repair)
        [I18n.t(:success, scope: 'services.command_service.set_responsible_for_repairs',
                          username: responsible_for_repair.player.telegram_username)]
      end

      def failure_response
        [I18n.t(:failure, scope: 'services.command_service.set_responsible_for_repairs')]
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
