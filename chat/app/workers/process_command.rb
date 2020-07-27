# frozen_string_literal: true

module Workers
  class ProcessCommand
    include Sidekiq::Worker
    sidekiq_options queue: :commands, retry: 2, backtrace: 20

    def perform(command, message_type)
      Chat::CommandService.new(command, message_type).call
    end
  end
end
