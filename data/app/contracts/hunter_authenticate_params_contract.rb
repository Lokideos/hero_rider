# frozen_string_literal: true

class HunterAuthenticateParamsContract < Dry::Validation::Contract
  params do
    required(:hunter_name).filled(:string)
    required(:sso_cookie).filled(:string)
  end
end
