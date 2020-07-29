# frozen_string_literal: true

class DeactivateHunterParamsContract < Dry::Validation::Contract
  params do
    required(:hunter_name).filled(:string)
  end
end
