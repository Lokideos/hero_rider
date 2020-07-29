# frozen_string_literal: true

module Chat
  module Command
    class HunterCredentials
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = RiderData::AuthenticateService.call(telegram_username, admin: true)
        return unless result.success?

        # name = @command[@message_type]['text'].split(' ')[1]
        # hunter = TrophyHunter.find(name: name)
        #
        # ["#{name} credentials: #{hunter.email} #{hunter.password}"] if hunter

        name = @command[@message_type]['text'].split(' ')[1]
        result = RiderData::Hunters::GetHunterService.call(name)

        @message = if result.success?
                     [I18n.t(:success, scope: 'services.command_service.hunter_credentials',
                                       name: result.hunter['name'], email: result.hunter['email'],
                                       password: result.hunter['password'])]
                   else
                     [I18n.t(:not_found, scope: 'services.command_service.hunter_credentials',
                                         name: name)]
                   end
      end
    end
  end
end
