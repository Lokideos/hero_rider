# frozen_string_literal: true

class AuthenticateParamsContract < Dry::Validation::Contract
  params do
    required(:username).filled(:string)
  end
end
