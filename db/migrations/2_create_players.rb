# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :players do
      primary_key :id
      String :telegram_username
      String :trophy_account, unique: true
      Boolean :admin
      Boolean :on_watch
      DateTime :created_at
      DateTime :updated_at
    end

    add_index :players, :telegram_username
    add_index :players, :trophy_account
    add_index :players, :admin
    add_index :players, :on_watch
  end

  down do
    drop_table :players
  end
end
