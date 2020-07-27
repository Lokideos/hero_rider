# frozen_string_literal: true

class GameAcquisition < Sequel::Model
  many_to_one :player
  many_to_one :game

  dataset_module do
    def find_progresses(game_id)
      where(game_id: game_id)
        .left_join(:players, id: :player_id)
        .order(:progress)
        .reverse
        .all
    end
  end
end
