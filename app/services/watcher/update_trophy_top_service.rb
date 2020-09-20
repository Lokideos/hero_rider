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

      Game.store_game_top(@trophy.game)
    end
  end
end
