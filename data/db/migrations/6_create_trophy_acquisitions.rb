# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :trophy_acquisitions do
      primary_key :id
      foreign_key :player_id
      foreign_key :trophy_id
      DateTime :earned_at
    end
  end

  down do
    drop_table :trophy_acquisitions
  end
end
