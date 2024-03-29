# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

ruby '2.7.5'

gem 'rake', '~> 13.0.0'
gem 'roda', '~> 3.34.0'
gem 'puma', '~> 5.6.4'
gem 'rack', '~> 2.2.3.1'

gem 'i18n', '~> 1.8.0'
gem 'config', '~> 2.2.0'

gem 'pg', '~> 1.2.3'
gem 'sequel', '~> 5.32.0'
gem 'redis', '~> 4.2.0'

gem "sidekiq", '~> 6.4.0'

gem 'dry-initializer', '~> 3.0.0'
gem 'dry-validation', '~> 1.5.0'

gem 'activesupport', '~> 6.1.0', require: false

gem 'faraday', '~> 1.10.0'
gem 'faraday_middleware', '~> 1.2.0'
gem "typhoeus", '~> 1.4.0'

gem 'oj', '~> 3.10.0'
gem 'slim', '~> 4.0.0'
gem 'pry', '~> 0.13.0'

gem 'logging', '~> 2.3.0'

group :development, :test do
  gem 'pry-byebug', '~> 3.9.0'
  gem 'rubocop', '0.89.1', require: false

  gem 'rspec', '~> 3.9.0'
  gem 'fabrication', '~> 2.21.0'
  gem 'rack-test', '~> 1.1.0'
  gem 'database_cleaner-sequel', '~> 1.8.0'
  gem 'rspec_sequel_matchers', '~> 0.5.0'
end

group :test do
  gem 'mock_redis', '~> 0.34.0'
end
