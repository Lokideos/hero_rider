# frozen_string_literal: true

module Players
  class DestroyService
    prepend BasicService

    param :username

    attr_reader :player

    def call
      @player = Player.find(telegram_username: @username)
      return fail_t!(:not_found) unless @player.present?

      RedisDb.redis.srem('holy_rider:watcher:players', @player.trophy_account)
      @player.remove_all_games
      @player.remove_all_trophies
      @player.delete

      Player.trophy_top_force_update
      Game.update_all_progress_caches

      # @player = Player.new(telegram_username: @username)
      # if @trophy_account.present?
      #   @player.trophy_account = @trophy_account
      #   @player.on_watch = true
      #   RedisDb.redis.sadd('holy_rider:watcher:players', @trophy_account)
      #   RedisDb.redis.set("holy_rider:watcher:players:initial_load:#{@trophy_account}", 'initial')
      # end
      #
      # if @player.valid?
      #   @player.save
      # else
      #   fail!(@player.errors)
      # end
    end

    private

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.players.destroy_service'))
    end
  end
end
