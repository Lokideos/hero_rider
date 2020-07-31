# frozen_string_literal: true

module Workers
  class ProcessMention
    include Sidekiq::Worker
    sidekiq_options queue: :mentions, retry: 2, backtrace: 20

    def perform(_command, _message_type)
      # TODO: add mentions processing
    end
  end
end
