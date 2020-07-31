# frozen_string_literal: true

module Chat
  class ProcessCommandsService
    prepend BasicService

    param :commands

    def call
      @commands.each do |command|
        Chat::MESSAGE_TYPES.each do |message_type|
          next unless command.key? message_type

          Workers::ProcessCommand.perform_async(command, message_type)
        end
      end
    end
  end
end
