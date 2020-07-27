# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :message_threads do
      primary_key :id
      foreign_key :player_id
      String :message_thread_id, null: false, unique: true
      String :last_modified_date
      String :last_message_index
      DateTime :created_at
      DateTime :updated_at
    end

    add_index :message_threads, :message_thread_id
  end

  down do
    drop_table :message_threads
  end
end
