# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :trophies do
      primary_key :id
      foreign_key :game_id
      # TODO: change trophy_service_id name (duplicate with games table)
      Integer :trophy_service_id, null: false
      String :trophy_name, null: false
      String :trophy_description, null: false
      String :trophy_type, null: false, index: true
      String :trophy_icon_url, null: false
      String :trophy_small_icon_url, null: false
      String :trophy_earned_rate, null: false
      Integer :trophy_rare, null: false
      Boolean :hidden, default: false, index: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
      DateTime :updated_at, null: false, index: true
    end
  end

  down do
    drop_table :trophies
  end
end
