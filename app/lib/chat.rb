# frozen_string_literal: true

module Chat
  extend self

  MESSAGE_TYPES = %w[message edited_message].freeze

  def interaction
    sleep(0.5)
    new_messages = chat_updates

    check_messages_for_deletion
    unless new_messages.any?
      CustomLogger.info(I18n.t(:no_updates, scope: 'logs.lib.chat'))
      return
    end

    Chat::ProcessCommandsService.call(commands(new_messages))
    Chat::ProcessMentionsService.call(mentions(new_messages))

    store_last_processed_message(new_messages.last['update_id'])

    CustomLogger.info(I18n.t(:end_of_interaction, scope: 'logs.lib.chat'))
  end

  private

  def commands(messages)
    MESSAGE_TYPES.flat_map do |message_type|
      select_messages_by_type(messages, message_type, 'bot_command')
    end
  end

  def mentions(messages)
    MESSAGE_TYPES.flat_map do |message_type|
      select_messages_by_type(messages, message_type, 'mention')
    end
  end

  def select_messages_by_type(messages, type, entity_type)
    messages.select do |message|
      message.dig(type, 'entities')&.any? { |entity| entity['type'] == entity_type }
    end
  end

  def store_last_processed_message(update_id)
    RedisDb.redis.set('holy_rider:bot:chat:last_processed_message_id', update_id)
  end

  def last_processed_message_id
    RedisDb.redis.get('holy_rider:bot:chat:last_processed_message_id').to_i
  end

  def clear_last_processed_message
    RedisDb.redis.del('holy_rider:bot:chat:last_processed_message_id')
  end

  def chat_updates
    all_recent_messages = Chat::ReceiveUpdatesService.call.updates['result']
    unless last_processed_message_id.zero?
      return all_recent_messages.select do |message|
        message['update_id'] > last_processed_message_id
      end
    end

    store_last_processed_message(all_recent_messages.last&.dig('update_id'))
    []
  end

  def check_messages_for_deletion
    RedisDb.redis.smembers('holy_rider:bot:messages:to_delete').each do |message_uid|
      next if RedisDb.redis.get("holy_rider:bot:messages:to_delete:expiration:#{message_uid}")

      Workers::ProcessMessageDeletion.perform_async(message_uid)
    end
  end
end
