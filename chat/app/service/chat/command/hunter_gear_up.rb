# frozen_string_literal: true

module Chat
  module Command
    class HunterGearUp
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = RiderData::AuthenticateService.call(telegram_username, admin: true)
        return unless result.success?

        message = @command[@message_type]['text'].split(' ')
        name = message[1]
        sso_cookie = message[2]
        result = RiderData::Hunters::GearUpService.call(name, sso_cookie)

        @message = if result.success?
                     [I18n.t(:success, scope: 'services.command_service.hunter_gear_up',
                                       name: name)]
                   else
                     [I18n.t(:failure, scope: 'services.command_service.hunter_gear_up',
                                       name: name)]
                   end
      end
    end
  end
end
