# frozen_string_literal: true

module Players
  class FindPlayerService
    prepend BasicService

    param :username

    attr_reader :player

    def call
      @player = Player.find(telegram_username: @username)

      valid?(@player) ? @player : fail_t!(:not_found)
    end

    def valid?(player)
      player.present?
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.players.find_player_service'))
    end
  end
end
