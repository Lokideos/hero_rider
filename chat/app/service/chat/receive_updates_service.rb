# frozen_string_literal: true

module Chat
  class ReceiveUpdatesService
    prepend BasicService

    option :client, default: proc { TelegramService::HttpClient.new }
    option :chat_id, default: proc { Settings.telegram.main_chat_id }

    attr_reader :updates

    def call
      @updates = @client.receive_updates(chat_id: @chat_id)
    end
  end
end
