# frozen_string_literal: true

class GameTopParamsContract < Dry::Validation::Contract
  params do
    required(:game_title).filled(:string)
  end
end
