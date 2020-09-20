# frozen_string_literal: true

class GameAcquisition < Sequel::Model
  many_to_one :player
  many_to_one :game

  dataset_module do
    def find_progresses(game_id)
      where(game_id: game_id)
        .inner_join(:players, id: :player_id)
        .reverse_order(:progress)
        .all
    end
  end
end
