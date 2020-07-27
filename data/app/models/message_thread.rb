# frozen_string_literal: true

class MessageThread < Sequel::Model
  many_to_one :player

  dataset_module do
    def selected_message_threads(thread_ids)
      where(message_thread_id: thread_ids).all
    end
  end
end
