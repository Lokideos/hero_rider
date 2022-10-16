# frozen_string_literal: true

module RedisDb
  module_function

  def redis
    @redis ||= case ENV['RACK_ENV']
               when 'test'
                 MockRedis.new(
                   host: Settings.redis.host,
                   port: Settings.redis.port,
                   db: Settings.redis.db
                 )
               else
                 Redis.new(
                   host: Settings.redis.host,
                   port: Settings.redis.port,
                   db: Settings.redis.db
                 )
               end
  end
end
