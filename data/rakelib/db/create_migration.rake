# frozen_string_literal: true

namespace :db do
  desc 'Create database migration'
  task :create_migration, [:name] do |_task, args|
    current_migrations =  Dir.entries('db/migrations/').map { |file| file if file =~ /.*.rb$/ }.
      compact
    version = current_migrations.map { |migration| migration[/^\d*/].to_i }.max || 0
    filepath = File.join(__dir__, '../', 'db', 'migrations', "#{version + 1}_#{args.name}.rb")
    migration_boilerplate = <<~CODE
      # frozen_string_literal: true
      
      Sequel.migration do
        up do
        end

        down do
        end
      end
    CODE

    File.write(filepath, migration_boilerplate)
  end
end
