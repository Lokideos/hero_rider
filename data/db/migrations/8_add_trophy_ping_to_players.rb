# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :players, :trophy_ping, TrueClass, default: false
  end

  down do
    drop_column :players, :trophy_ping
  end
end
