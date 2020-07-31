# frozen_string_literal: true

class GameFromCacheParamsContract < Dry::Validation::Contract
  params do
    required(:game_index).filled(:string)
    required(:player_name).filled(:string)
  end
end
