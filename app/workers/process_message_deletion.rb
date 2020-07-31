# frozen_string_literal: true

module Workers
  class ProcessMessageDeletion
    include Sidekiq::Worker
    sidekiq_options queue: :commands, retry: 2, backtrace: 20

    def perform(message_uid)
      Chat::DeleteMessageService.call(message_uid)
    end
  end
end
