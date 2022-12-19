# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :trophy_hunters, :authorization_token, String
  end

  down do
    drop_column :trophy_hunters, :authorization_token
  end
end
