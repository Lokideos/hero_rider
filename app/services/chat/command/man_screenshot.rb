# frozen_string_literal: true

module Chat
  module Command
    class ManScreenshot
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        message = ['<b>Загрузка скриншота</b>']
        message << 'Для загрузки скриншота отправьте его через psn на аккаунт бота.'
        message << "На данный момент это <code>#{Settings.telegram.screenshot_worker}</code>."
        message << 'Через какое-то время скриншот появится в чате с указанием на того, ' \
                   'кто его отправил.'

        @message = [message.join("\n")]
      end
    end
  end
end
