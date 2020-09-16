# frozen_string_literal: true

require_relative 'http_api/auth'
require_relative 'http_api/trophies'

module PsnService
  module HttpApi
    include Auth
    include Trophies
  end
end
