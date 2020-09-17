# frozen_string_literal: true

module Workers
  class ProcessFileDeletion
    include Sidekiq::Worker
    sidekiq_options queue: :screenshots, retry: 5, backtrace: 20

    def perform(filepath)
      File.delete filepath if File.exist? filepath
    end
  end
end
