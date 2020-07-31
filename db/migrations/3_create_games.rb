# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :games do
      primary_key :id
      String :trophy_service_id
      String :title
      String :platform
      String :icon_url
      DateTime :created_at
      DateTime :updated_at
    end

    add_index :games, :trophy_service_id
    add_index :games, :title
  end

  down do
    drop_table :games
  end
end
