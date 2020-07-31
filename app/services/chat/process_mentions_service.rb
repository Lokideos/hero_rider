# frozen_string_literal: true

module Chat
  class ProcessMentionsService
    prepend BasicService

    param :mentions

    def call
      @mentions.each do |mention|
        Chat::MESSAGE_TYPES.each do |message_type|
          next unless mention.key? message_type

          Workers::ProcessMention.perform_async(mention, message_type)
        end
      end
    end
  end
end
