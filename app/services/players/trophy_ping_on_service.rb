# frozen_string_literal: true

module Players
  class TrophyPingOnService
    prepend BasicService

    param :username

    attr_reader :player

    def call
      @player = Player.find(telegram_username: @username)
      return fail_t!(:already_pinged_on) if @player.trophy_ping_on?

      @player.update(trophy_ping: true)
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.players.trophy_ping_on_service'))
    end
  end
end
