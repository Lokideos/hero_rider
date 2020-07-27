# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :players, :message_thread_name, String
  end

  down do
    drop_column :players, :message_thread_name
  end
end
