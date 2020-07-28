# frozen_string_literal: true

class ActivateHunterParamsContract < Dry::Validation::Contract
  params do
    required(:hunter_name).filled(:string)
  end
end
