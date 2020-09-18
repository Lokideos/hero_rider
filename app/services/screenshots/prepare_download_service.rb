# frozen_string_literal: true

module Screenshots
  class PrepareDownloadService
    prepend BasicService

    option :threads
    option :token

    def call
      @threads.each do |thread|
        Workers::ProcessScreenshotDownloadPrep.perform_async(thread, @token)
      end
    end
  end
end
