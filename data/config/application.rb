# frozen_string_literal: true

class Application < Roda
  def self.root
    File.expand_path('..', __dir__)
  end

  plugin(:not_found) { { error: 'Not found' } }
  plugin :environments
  plugin :json_parser
end
