# frozen_string_literal: true

module Games
  class RelevantGamesService
    prepend BasicService

    param :game_title
    param :player_name

    attr_reader :games_list

    def call
      @games_list = Game.relevant_games(@game_title, @player_name)
                        .map { |game| "#{game.title} #{game.platform}" }

      valid?(@games_list) ? @games_list : fail_t!(:not_found)
    end

    def valid?(relevant_games)
      relevant_games.present?
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.games.relevant_games_service'))
    end
  end
end
