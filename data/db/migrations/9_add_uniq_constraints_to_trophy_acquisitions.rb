# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table :trophy_acquisitions do
      add_unique_constraint %i[player_id trophy_id]
    end
  end

  down do
    alter_table :trophy_acquisitions do
      drop_constraint(:trophy_acquisitions_player_id_trophy_id_key, type: :unique)
    end
  end
end
