# frozen_string_literal: true

module Chat
  module Command
    class SendDelayedMessages
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(telegram_username)
        return unless result.success?

        delayed_messages = RedisDb.redis.smembers('holy_rider:delayed_messages')
        delayed_messages.each.with_index do |index|
          message = RedisDb.redis.get("holy_rider:delayed_messages:#{index}:message")
          sticker = RedisDb.redis.get("holy_rider:delayed_messages:#{index}:sticker")
          RedisDb.redis.del("holy_rider:delayed_messages:#{index}:message")
          RedisDb.redis.del("holy_rider:delayed_messages:#{index}:sticker")
          Chat::SendChatMessageService.call(message)
          Chat::SendStickerService.call(sticker) if sticker.present?
        end

        message = []
        if delayed_messages.size > 0
          RedisDb.redis.del('holy_rider:delayed_messages')
          message << 'Отложенные сообщения успешно отправлены.'
        else
          message << 'Нет отложенных сообщений.'
        end

        @message = [message.join("\n")]
      end
    end
  end
end
