# frozen_string_literal: true

module Players
  class WatchOnService
    prepend BasicService

    param :username

    attr_reader :player

    def call
      @player = Player.find(telegram_username: @username)
      return fail_t!(:not_found) unless @player.present?

      return fail_t!(:already_watched_on, name: @username) if @player.on_watch?

      @player.update(on_watch: true)
      RedisDb.redis.sadd('holy_rider:watcher:players', @player.trophy_account)
    end

    def fail_t!(key, name: nil)
      fail!(I18n.t(key, scope: 'services.players.watch_on_service', name: name))
    end
  end
end
