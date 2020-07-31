# frozen_string_literal: true

module Players
  class AdminAuthenticateService
    prepend BasicService

    param :username

    attr_reader :player

    def call
      @player = Player.find(telegram_username: @username)

      valid?(@player) ? @player : fail_t!(:unauthorized)
    end

    def valid?(player)
      player.admin?
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.players.admin_authenticate_service'))
    end
  end
end
