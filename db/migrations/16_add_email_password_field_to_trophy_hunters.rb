# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :trophy_hunters, :email_password, String
  end

  down do
    drop_column :trophy_hunters, :email_password
  end
end
