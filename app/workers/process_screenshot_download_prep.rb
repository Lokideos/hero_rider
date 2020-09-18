# frozen_string_literal: true

module Workers
  class ProcessScreenshotDownloadPrep
    include Sidekiq::Worker
    sidekiq_options queue: :screenshots, retry: 5, backtrace: 20

    def perform(message_thread, token)
      Screenshots::ProcessMessagesService.call(message_thread: message_thread, token: token)
    end
  end
end
