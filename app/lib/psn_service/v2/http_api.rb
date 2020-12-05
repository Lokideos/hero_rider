# frozen_string_literal: true

require_relative 'http_api/auth'
require_relative 'http_api/trophies'
# require_relative 'http_api/profile'
# require_relative 'http_api/threads'

module PsnService
  module V2
    module HttpApi
      include Auth
      include Trophies
      # include Profile
      # include Threads
    end
  end
end
