# frozen_string_literal: true

module Chat
  class SendChatMessageService
    prepend BasicService

    DEFAULT_EXPIRATION_TIME = Game::GAME_CACHE_EXPIRE

    param :message
    param :to_delete, default: proc { false }
    param :chat_id, default: proc { Settings.telegram.main_chat_id }
    option :client, default: proc { TelegramService::HttpClient.new }

    def call
      response = @client.send_message(chat_id: @chat_id, message: @message)
      return response unless @to_delete

      set_up_for_deletion(response)
    end

    private

    def set_up_for_deletion(response)
      message_id = response.body.dig('result', 'message_id')
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
