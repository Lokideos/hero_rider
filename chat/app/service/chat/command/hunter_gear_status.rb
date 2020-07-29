# frozen_string_literal: true

module Chat
  module Command
    class HunterGearStatus
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = RiderData::AuthenticateService.call(telegram_username, admin: true)
        return unless result.success?

        name = @command[@message_type]['text'].split(' ')[1]
        result = RiderData::Hunters::HunterGearStatusService.call(name)
        @message = if result.success?
                     [I18n.t(:success, scope: 'services.command_service.hunter_gear_status',
                                       name: name)]
                   else
                     result.errors
                   end
      end
    end
  end
end
