# frozen_string_literal: true

Sequel.migration do
  no_transaction

  up do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    add_index :games, :title, name: :games_title_trgm_index, type: :gin, opclass: :gin_trgm_ops,
              concurrently: true
  end

  down do
    drop_index :games, :title, name: :games_title_trgm_index
    execute "DROP EXTENSION IF EXISTS pg_trgm;"
  end
end
