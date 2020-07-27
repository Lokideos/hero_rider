# frozen_string_literal: true

require 'sequel/core'

namespace :db do
  desc 'Create database'
  task create: :settings do
    CONNECTION_PARAMETERS = %i[adapter host port user password]

    Sequel.connect(Settings.db.to_hash.slice(*CONNECTION_PARAMETERS)) do |db|
      db.execute "CREATE DATABASE #{Settings.db.to_hash[:database]}"
    end
    Rake::Task['db:add_extensions'].execute
  end
end
