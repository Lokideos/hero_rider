# frozen_string_literal: true

module Screenshots
  class CreateMessageThreadsService
    prepend BasicService

    option :message_threads

    def call
      prepared_threads = @message_threads.map do |thread|
        {
          id: thread['threadId'],
          date: thread['threadModifiedDate'],
          message_thread_name: thread['latestMessageEventDetail']['sender']['onlineId']
        }
      end

      prepared_threads.each do |thread|
        player = Player.find(message_thread_name: thread[:message_thread_name])
        player&.add_message_thread(
          MessageThread.new(message_thread_id: thread[:id], last_modified_date: thread[:date])
        )
      end
    end
  end
end
