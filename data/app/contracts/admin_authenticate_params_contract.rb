# frozen_string_literal: true

class AdminAuthenticateParamsContract < Dry::Validation::Contract
  params do
    required(:username).filled(:string)
  end
end
