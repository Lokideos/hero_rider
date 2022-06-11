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
        result = ::Players::AdminAuthenticateService.call(telegram_username)
        return unless result.success?

        name = @command[@message_type]['text'].split(' ')[1]
        result = ::Hunters::GetHunterService.call(name)

        @message = if result.success?
                     [
                       '<b>Name:</b>' + ' ' * 36 + "<code>#{result.hunter.name}</code>\n" \
                       '<b>Email:</b>' + ' ' * 37 + "<code>#{result.hunter.email}</code>\n" \
                       "<b>Trophy Service Password:</b> <code>#{result.hunter.password}</code>\n" \
                       '<b>Email Password:</b>' + ' ' * 18 + "<code>#{result.hunter.email_password}</code>"
                     ]
                   else
                     [I18n.t(:not_found, scope: 'services.command_service.hunter_credentials',
                                         name: name)]
                   end
      end
    end
  end
end
