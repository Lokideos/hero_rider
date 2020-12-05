# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :trophy_hunters, :trophy_user_id, String
  end

  down do
    drop_column :trophy_hunters, :trophy_user_id
  end
end
