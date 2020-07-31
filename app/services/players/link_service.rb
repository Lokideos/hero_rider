# frozen_string_literal: true

module Players
  class LinkService
    prepend BasicService

    param :username
    param :trophy_account

    attr_reader :player

    def call
      @player = Player.find(telegram_username: @username)
      return fail_t!(:not_found) unless @player.present?

      @player.update(trophy_account: @trophy_account)
      @player.on_watch = true
      RedisDb.redis.sadd('holy_rider:watcher:players', @trophy_account)
      RedisDb.redis.set("holy_rider:watcher:players:initial_load:#{@trophy_account}", 'initial')
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.players.link_service'))
    end
  end
end
