# frozen_string_literal: true

class TrophyAcquisition < Sequel::Model
  many_to_one :player
  many_to_one :trophy

  dataset_module do
    def platinum_game_acquisition(game_id, player_id)
      select(:earned_at)
        .inner_join(:trophies, id: :trophy_id)
        .where(game_id: game_id, trophy_type: Trophy::PLATINUM_TROPHY_TYPE, player_id: player_id)
        .first
    end

    def first_game_acquisition(game_id, player_id)
      inner_join(:trophies, id: :trophy_id)
        .where(player_id: player_id, game_id: game_id)
        .order(:earned_at)
        .limit(1)
        .first
    end
  end
end
