# frozen_string_literal: true

class Application < Roda
  def self.root
    File.expand_path('..', __dir__)
  end

  plugin :error_handler do |e|
    case e
    when Sequel::NoMatchingRow
      response['Content-Type'] = 'application/json'
      response.status = 422
      error_response I18n.t(:not_found, scope: 'api.errors')
    when Sequel::UniqueConstraintViolation
      response['Content-Type'] = 'application/json'
      response.status = 422
      error_response I18n.t(:not_unique, scope: 'api.errors')
    when Validations::InvalidParams, KeyError
      response['Content-Type'] = 'application/json'
      response.status = 422
      error_response I18n.t(:missing_parameters, scope: 'api.errors')
    else
      raise
    end
  end
  plugin(:not_found) { { error: 'Not found' } }
  plugin :environments
  plugin :json_parser
  include Validations
  include ApiErrors

  route do |r|
    r.root do
      response['Content-Type'] = 'application/json'
      response.status = 200
      { status: 'ok' }.to_json
    end

    r.on 'v1' do
      r.get 'game_top' do
        game_top_params = validate_with!(GameTopParamsContract, params).to_h.values
        result = Games::TopGameService.call(*game_top_params)

        response['Content-Type'] = 'application/json'
        if result.success?
          response.status = 200
          result.game_top.to_json
        else
          response.status = 404
          error_response(result.errors)
        end
      end
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
