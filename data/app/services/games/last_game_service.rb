# frozen_string_literal: true

module Games
  class LastGameService
    prepend BasicService

    attr_reader :game_top

    def call
      @game_top = Game.find_last_game

      valid?(@game_top) ? @game_top : fail_t!(:failure)
    end

    def valid?(game_top)
      game_top.present?
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.games.last_game_service'))
    end
  end
end
