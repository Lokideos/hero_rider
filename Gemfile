# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'rake', '~> 13.0.0'
gem 'roda', '~> 3.34.0'
gem 'puma', '~> 5.0.0'

gem 'i18n', '~> 1.8.0'
gem 'config', '~> 2.2.0'

gem 'pg', '~> 1.2.3'
gem 'sequel', '~> 5.32.0'
gem 'redis', '~> 4.2.0'

gem "sidekiq", '~> 6.1.0'

gem 'dry-initializer', '~> 3.0.0'
gem 'dry-validation', '~> 1.5.0'

gem 'activesupport', '~> 6.0.0', require: false

gem 'faraday', '~> 1.0.0'
gem 'faraday_middleware', '~> 1.0.0'
gem "typhoeus", '~> 1.3.0'

gem 'oj', '~> 3.10.0'
gem 'slim', '~> 4.0.0'
gem 'pry', '~> 0.13.0'

group :development, :test do
  gem 'pry-byebug', '~> 3.9.0'

  gem 'rspec', '~> 3.9.0'
  gem 'fabrication', '~> 2.21.0'
  gem 'rack-test', '~> 1.1.0'
  gem 'database_cleaner-sequel', '~> 1.8.0'

  gem 'rack-unreloader', '~> 1.7.0'
end