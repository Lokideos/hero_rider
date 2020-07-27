# frozen_string_literal: true

module Chat
  class SendChatMessageService
    prepend BasicService

    # Should be same as expiration time in Game model for now
    DEFAULT_EXPIRATION_TIME = 300

    param :message
    option :client, default: proc { TelegramService::HttpClient.new }
    option :chat_id, default: proc { Settings.telegram.main_chat_id }
    option :to_delete, default: proc { false }

    def call
      message = @client.send_message(chat_id: @chat_id, message: @message[:message])
      return message unless @to_delete

      set_up_for_deletion(message)
    end

    private

    def set_up_for_deletion(message)
      message_id = message.dig('result', 'message_id')
      uid = Digest::SHA2.new.hexdigest([@chat_id, message_id].join)
      RedisDb.redis.sadd('holy_rider:bot:messages:to_delete', uid)
      RedisDb.redis.setex("holy_rider:bot:messages:to_delete:expiration:#{uid}",
                          DEFAULT_EXPIRATION_TIME,
                          'present')
      message_info = { chat_id: @chat_id, message_id: message_id }
      RedisDb.redis.hmset("holy_rider:bot:messages:to_delete:info:#{uid}", message_info.flatten)
    end
  end
end
