# frozen_string_literal: true

module Workers
  class ProcessImageUpload
    include Sidekiq::Worker
    sidekiq_options queue: :screenshots, retry: 5, backtrace: 20

    def perform(player_name, filename)
      filepath = Application.root.concat("/screenshots/#{filename}")

      Chat::UploadImageService.call(player_name: player_name, filepath: filepath)

      Workers::ProcessFileDeletion.perform_async(filepath)
    end
  end
end
