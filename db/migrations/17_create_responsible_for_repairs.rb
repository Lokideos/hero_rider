# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:responsible_for_repairs) do
      primary_key :id
      foreign_key :player_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :responsible_for_repairs
  end
end
