# frozen_string_literal: true

module Games
  class TopGameService
    prepend BasicService

    param :game_title

    attr_reader :game_top

    def call
      @game_top = Game.top_game(@game_title[:game_title])

      valid?(@game_top) ? @game_top : fail_t!(:not_found)
    end

    def valid?(game_top)
      game_top.present?
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.games.top_game_service'))
    end
  end
end
