# frozen_string_literal: true

module Workers
  class ProcessScreenshotDownload
    include Sidekiq::Worker
    sidekiq_options queue: :screenshots, retry: 5, backtrace: 20

    def perform(message, token, sender_name)
      Screenshots::DownloadScreenshotService.call(message: message, token: token,
                                                  sender_name: sender_name)
    end
  end
end
