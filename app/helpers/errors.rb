# frozen_string_literal: true

module Errors
  def not_found_response
    response['Content-Type'] = 'application/json'
    response.status = 404
    { status: 'Page not found' }.to_json
  end
end
