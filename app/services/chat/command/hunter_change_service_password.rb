# frozen_string_literal: true

module Chat
  module Command
    class HunterChangeServicePassword
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(telegram_username)
        return unless result.success?

        name = @command[@message_type]['text'].split(' ')[1]
        new_password = @command[@message_type]['text'].split(' ')[2]
        result = ::Hunters::ChangeServicePasswordService.call(name, new_password)

        @message = if result.success?
                     ["Пароль для охотника #{name} успешно обновлен"]
                   else
                     result.errors
                   end
      end
    end
  end
end
