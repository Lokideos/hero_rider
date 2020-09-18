# frozen_string_literal: true

module Watcher
  class UpdateTrophyTopService
    prepend BasicService

    option :player_id
    option :trophy_id
    option :player, default: proc { Player.find(id: player_id) }
    option :trophy, default: proc { Trophy.find(id: trophy_id) }

    def call
      @player.update_trophy_points
      @player.update_rare_points

      game = @trophy.game
      prepared_game = Game.find_exact_game(game.title, game.platform)
      Game.store_game_top(prepared_game)
    end
  end
end
