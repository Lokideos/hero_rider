# frozen_string_literal: true

module Players
  class TrophyPingOffService
    prepend BasicService

    param :username

    attr_reader :player

    def call
      @player = Player.find(telegram_username: @username)
      return fail_t!(:already_pinged_off) unless @player.trophy_ping_on?

      @player.update(trophy_ping: false)
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.players.trophy_ping_off_service'))
    end
  end
end
