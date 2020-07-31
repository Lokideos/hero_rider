# frozen_string_literal: true

class HunterParamsContract < Dry::Validation::Contract
  params do
    required(:hunter_name).filled(:string)
  end
end
