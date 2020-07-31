# frozen_string_literal: true

class RelevantGamesParamsContract < Dry::Validation::Contract
  params do
    required(:game_title).filled(:string)
    required(:player_name).filled(:string)
  end
end
