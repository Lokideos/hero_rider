# frozen_string_literal: true

module Watcher
  class NotifyForbiddenStatusService
    prepend BasicService

    NOTIFY_TIME_INTERVAL = 86_400

    param :player_name
    option :access_key, default: proc { "holy_rider:watcher:notification_interval:forbidden_request:#{@player_name}" }
    option :chat_id, default: proc { Settings.telegram.admin_chat_id }

    def call
      return unless Player.find(trophy_account: @player_name).present?

      return if RedisDb.redis.exists?(@access_key)

      message = I18n.t('watcher.trophy_access_forbidden', player_name: player)
      Chat::SendChatMessageService.new(message, false, @chat_id).call
      RedisDb.redis.setex(@access_key, NOTIFY_TIME_INTERVAL, 'notification_sent')
    end
  end
end
