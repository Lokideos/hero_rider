# frozen_string_literal: true

module Watcher
  class NotifyForbiddenStatusService
    prepend BasicService

    NOTIFY_TIME_INTERVAL = 86_400

    param :player_name
    option :access_key, default: proc { "watcher:notification_interval:forbidden_request:#{@player_name}" }
    option :chat_id, default: proc { Settings.telegram.admin_chat_id }
    option :storage, default: proc { Storage::Cache.new }

    def call
      return unless Player.find(trophy_account: @player_name).present?

      return if @storage.exists?(key: @access_key)

      message = I18n.t('watcher.trophy_access_forbidden', player_name: @player_name)
      Chat::SendChatMessageService.new(message, false, @chat_id).call
      @storage.store_for_period(key: @access_key, period: NOTIFY_TIME_INTERVAL, value: 'notification_sent')
    end
  end
end
