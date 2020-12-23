# frozen_string_literal: true

module Screenshots
  class ProcessMessagesService
    prepend BasicService

    option :message_thread
    option :token
    option :client, default: proc {
      PsnService::V1::HttpClient.new(url: Settings.psn.v1.threads.url)
    }

    def call
      db_thread = MessageThread.find(message_thread_id: @message_thread['threadId'])
      return unless db_thread.present?

      sender_name = db_thread.player.telegram_username
      messages = @client.request_messages_from_thread(thread_id: @message_thread['threadId'],
                                                      token: @token)
      last_processed_message = messages.find do |message|
        message['messageEventDetail']['eventIndex'] == db_thread.last_message_index
      end
      last_message_index = messages.index(last_processed_message)
      new_messages = messages[0..last_message_index&.-(1)]
      image_messages = new_messages.select do |message|
        message['messageEventDetail']['eventCategoryCode'] == 3
      end

      image_messages.each do |message|
        Workers::ProcessScreenshotDownload.perform_async(message, @token, sender_name)
      end

      db_thread.update(last_message_index: messages[0]['messageEventDetail']['eventIndex'])
    end
  end
end
