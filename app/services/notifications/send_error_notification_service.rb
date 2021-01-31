# frozen_string_literal: true

module Notifications
  class SendErrorNotificationService
    prepend BasicService

    SECONDS_IN_DAY = 86_400
    LOCKED_NOTIFICATION_MESSAGE = 'locked'

    param :exception
    param :repeat_notification
    option :admin_chat_id, default: proc { Settings.telegram.admin_chat_id }

    def call
      message = "#log #error #{@exception.message}"

      return if repeat_lock_exists?

      Chat::SendChatMessageService.new(message, false, @admin_chat_id).call
      set_repeat_lock unless notification_repeatable?
    end

    private

    def notification_repeatable?
      @repeat_notification
    end

    def repeat_lock_exists?
      RedisDb.redis.exists?("hero_rider:exceptions:repeat_lock:#{@exception.message}")
    end

    def set_repeat_lock
      RedisDb.redis.setex("hero_rider:exceptions:repeat_lock:#{@exception.message}",
                          SECONDS_IN_DAY,
                          LOCKED_NOTIFICATION_MESSAGE)
    end
  end
end
