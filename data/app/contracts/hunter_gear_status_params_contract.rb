# frozen_string_literal: true

class HunterGearStatusParamsContract < Dry::Validation::Contract
  params do
    required(:hunter_name).filled(:string)
  end
end
