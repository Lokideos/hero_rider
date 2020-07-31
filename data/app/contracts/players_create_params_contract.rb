# frozen_string_literal: true

class PlayersCreateParamsContract < Dry::Validation::Contract
  params do
    required(:username).filled(:string)
    required(:trophy_account)
  end
end
