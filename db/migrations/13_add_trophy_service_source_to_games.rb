# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :games, :trophy_service_source, String, default: 'trophy'
  end

  down do
    drop_column :games, :trophy_service_source
  end
end
