# frozen_string_literal: true

require_relative 'http_api/auth'
require_relative 'http_api/trophies'
require_relative 'http_api/profile'

module PsnService
  module HttpApi
    include Auth
    include Trophies
    include Profile
  end
end
