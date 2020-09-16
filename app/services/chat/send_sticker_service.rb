# frozen_string_literal: true

module Chat
  class SendStickerService
    prepend BasicService

    param :sticker
    param :chat_id, default: proc { Settings.telegram.main_chat_id }
    option :client, default: proc { TelegramService::HttpClient.new }

    def call
      @client.send_sticker(chat_id: @chat_id, sticker: @sticker)
    end
  end
end
