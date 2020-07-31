# frozen_string_literal: true

module Chat
  module Command
    class HunterDeactivate
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(telegram_username)
        return unless result.success?

        name = @command[@message_type]['text'].split(' ')[1]
        result = ::Hunters::DeactivateHunterService.call(name)

        @message = if result.success?
                     [I18n.t(:success, scope: 'services.command_service.hunter_deactivate',
                                       name: name)]
                   else
                     [I18n.t(:not_found, scope: 'services.command_service.hunter_deactivate',
                                         name: name)]
                   end
      end
    end
  end
end
