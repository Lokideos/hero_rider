# frozen_string_literal: true

module Games
  class GameFromCacheService
    prepend BasicService

    param :player_name
    param :game_index

    attr_reader :game_from_cache

    def call
      @game_from_cache = Game.find_game_from_cache(@player_name, @game_index)

      valid?(@game_from_cache) ? @game_from_cache : fail_t!(:not_found)
    end

    def valid?(game_from_cache)
      game_from_cache.present? && game_from_cache != 'null'
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.games.game_from_cache_service'))
    end
  end
end
