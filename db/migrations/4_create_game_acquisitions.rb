# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :game_acquisitions do
      primary_key :id
      foreign_key :player_id
      foreign_key :game_id
      Integer :progress
      DateTime :last_updated_date
    end

    add_index :game_acquisitions, :last_updated_date
  end

  down do
    drop_table :game_acquisitions
  end
end
