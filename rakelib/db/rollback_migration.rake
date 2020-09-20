# frozen_string_literal: true

require 'sequel/core'
require 'pry-byebug'

namespace :db do
  desc 'Rollback migration'
  task :rollback, [:version] => :settings do |_task, args|
    Sequel.extension :migration
    migrations = File.expand_path('../../db/migrations', __dir__)

    @db = Sequel.connect(Settings.db.to_hash)

    args.with_defaults(version: (@db[:schema_info].first[:version] - 1) || 0)

    Sequel::Migrator.run(@db, migrations, target: args.version.to_i)

    Rake::Task['db:schema'].execute
    Rake::Task['db:version'].execute
  end
end
