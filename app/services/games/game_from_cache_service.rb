# frozen_string_literal: true

module Games
  class GameFromCacheService
    prepend BasicService

    param :player_name
    param :game_index

    attr_reader :cached_game_top

    def call
      @cached_game_top = Game.find_game_from_cache(@player_name, @game_index)

      valid?(@cached_game_top) ? @cached_game_top : fail_t!(:not_found)
    end

    def valid?(game_from_cache)
      game_from_cache.present? && game_from_cache != 'null'
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.games.game_from_cache_service'))
    end
  end
end
