# frozen_string_literal: true

class PlayerInfoParamsContract < Dry::Validation::Contract
  params do
    required(:username).filled(:string)
  end
end
