# frozen_string_literal: true

require 'spec_helper'

ENV['RACK_ENV'] ||= 'test'

require_relative '../config/environment'

abort('You run tests in production mode. Please don\'t do this!') if Application.environment == :production
Dir[Application.root.concat('/spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RspecSequel::Matchers

  config.before(:each) do
    RedisDb.redis.flushdb
  end
end
