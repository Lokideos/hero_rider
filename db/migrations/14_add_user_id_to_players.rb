# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :players, :trophy_user_id, String
  end

  down do
    drop_column :players, :trophy_user_id
  end
end
