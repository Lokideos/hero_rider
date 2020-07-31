# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :trophy_hunters do
      primary_key :id
      String :name, unique: true, null: false
      String :email, unique: true, null: false
      String :password, null: false
      String :app_context, null: false, default: 'inapp_ios'
      String :client_id, null: false, unique: true
      String :client_secret, null: false, unique: true
      String :duid, null: false
      String :state, null: false
      String :scope, null: false
      Boolean :active, default: false
      String :refresh_token
      DateTime :refresh_token_expiration
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    add_index :trophy_hunters, :name
  end

  down do
    drop_table(:trophy_hunters)
  end
end
