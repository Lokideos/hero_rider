# frozen_string_literal: true

module Chat
  class DeleteMessageService
    prepend BasicService

    param :message_uid
    option :client, default: proc { TelegramService::HttpClient.new }

    def call
      message_info = RedisDb.redis.hgetall("holy_rider:bot:messages:to_delete:info:#{@message_uid}")
      return if message_info.empty?

      @client.delete_message(chat_id: message_info['chat_id'],
                             message_id: message_info['message_id'])

      RedisDb.redis.srem('holy_rider:bot:messages:to_delete', @message_uid)
      RedisDb.redis.del("holy_rider:bot:messages:to_delete:info:#{@message_uid}")
    end
  end
end
