# frozen_string_literal: true

module Bot
  class UploadImageService
    prepend BasicService

    option :filepath
    option :player_name
    option :chat_id, default: proc { Settings.telegram.main_chat_id }
    option :client, default: proc { TelegramService::HttpClient.new }

    def call
      caption = "<code>#{@player_name}</code> присылает скриншот"
      @client.send_image(chat_id: @chat_id, filepath: @filepath, caption: caption)
    end
  end
end
