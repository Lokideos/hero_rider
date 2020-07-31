require_relative 'config/environment'

if ENV["RACK_ENV"] == "development"
  require "rack/unreloader"
  unreloader = Rack::Unreloader.new(subclasses: %w[Application], reload: true) { Application }
  Dir.glob("app/**/*.rb").each { |file_name| unreloader.require(file_name) }
  Dir.glob("config/application.rb").each { |file_name| unreloader.require(file_name) }
  run unreloader
else
  run Application.freeze.app
end