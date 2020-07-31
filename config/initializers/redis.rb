# frozen_string_literal: true

module RedisDb
  module_function

  def redis
    @redis ||= Redis.new(
      host: Settings.redis.host,
      port: Settings.redis.port,
      db: Settings.redis.db
    )
  end
end
