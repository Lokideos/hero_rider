# frozen_string_literal: true

class Application < Roda
  def self.root
    File.expand_path('..', __dir__)
  end
  plugin(:not_found) do
    response['Content-Type'] = 'application/json'
    response.status = 200
    { status: 'Page not found' }.to_json
  end
  plugin :environments
  plugin :json_parser

  route do |r|
    r.root do
      response['Content-Type'] = 'application/json'
      response.status = 200
      { status: 'ok' }.to_json
    end

    r.on 'trophy' do
      r.run TrophiesRoute
    end

    r.get 'favicon.ico' do
      'no icon'
    end
  end

  private

  def params
    request.params
  end
end
