# frozen_string_literal: true

module Players
  class ReloadService
    prepend BasicService

    param :username

    attr_reader :player

    def call
      @player = Player.find(telegram_username: @username)
      return fail_t!(:not_found) unless @player.present?

      TrophyAcquisition.where(player: @player).delete
      GameAcquisition.where(player: @player).delete
      @player.update(on_watch: true)
      @player.reload
      RedisDb.redis.set("holy_rider:watcher:players:initial_load:#{@player.trophy_account}",
                        'initial')
      Player.trophy_top_force_update
      Game.update_all_progress_caches
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.players.reload_service'))
    end
  end
end
