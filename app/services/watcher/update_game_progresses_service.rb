# frozen_string_literal: true

module Watcher
  class UpdateGameProgressesService
    prepend BasicService

    option :game_id
    option :game, default: proc { Game.find(id: game_id) }

    def call
      @game.update_top_progresses
    end
  end
end
