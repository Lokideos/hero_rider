# frozen_string_literal: true

module Storage
  class Cache
    GENERAL_NAMESPACE_KEY = "#{Settings.app.name}:"

    def store_for_period(key:, period:, value:)
      RedisDb.redis.setex(namespaced(key), period, value)
    end

    def exists?(key:)
      RedisDb.redis.exists?(namespaced(key))
    end

    private

    def namespaced(key)
      GENERAL_NAMESPACE_KEY + key
    end
  end
end
