# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :players, :trophy_level, Integer, default: 0
    add_column :players, :level_up_progress, Integer, default: 0
  end

  down do
    drop_column :players, :trophy_level
    drop_column :players, :level_up_progress
  end
end
