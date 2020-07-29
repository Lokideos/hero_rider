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

      r.get 'relevant_games' do
        relevant_games_params = validate_with!(RelevantGamesParamsContract, params).to_h.values
        result = Games::RelevantGamesService.call(*relevant_games_params)

        response['Content-Type'] = 'application/json'
        if result.success?
          response.status = 200
          result.relevant_games.to_json
        else
          response.status = 404
          error_response(result.errors)
        end
      end

      r.get 'game_from_cache' do
        game_from_cache_params = validate_with!(GameFromCacheParamsContract, params).to_h.values
        result = Games::GameFromCacheService.call(*game_from_cache_params)

        response['Content-Type'] = 'application/json'
        if result.success?
          response.status = 200
          result.game_from_cache.to_json
        else
          response.status = 404
          error_response(result.errors)
        end
      end

      r.post 'activate_hunter' do
        activate_hunter_params = validate_with!(ActivateHunterParamsContract, params).to_h.values
        result = Hunters::ActivateHunterService.call(*activate_hunter_params)

        response['Content-Type'] = 'application/json'
        if result.success?
          response.status = 200
          result.hunter.to_json
        else
          response.status = 422
          error_response(result.errors)
        end
      end

      r.post 'deactivate_hunter' do
        deactivate_hunter_params = validate_with!(DeactivateHunterParamsContract, params).to_h
                                                                                         .values
        result = Hunters::DeactivateHunterService.call(*deactivate_hunter_params)

        response['Content-Type'] = 'application/json'
        if result.success?
          response.status = 200
          result.hunter.to_json
        else
          response.status = 422
          error_response(result.errors)
        end
      end

      r.get 'hunter' do
        hunter_params = validate_with!(HunterParamsContract, params).to_h.values
        result = Hunters::GetHunterService.call(*hunter_params)

        response['Content-Type'] = 'application/json'
        if result.success?
          response.status = 200
          result.hunter.to_json
        else
          response.status = 404
          error_response(result.errors)
        end
      end

      r.get 'hunter_gear_status' do
        hunter_gear_status_params = validate_with!(HunterGearStatusParamsContract, params).to_h
                                                                                          .values
        result = Hunters::GetHunterGearStatusService.call(*hunter_gear_status_params)

        response['Content-Type'] = 'application/json'
        if result.success?
          response.status = 200
          result.hunter.to_json
        else
          response.status = 422
          error_response(result.errors)
        end
      end

      r.post 'authenticate' do
        authenticate_params = validate_with!(AuthenticateParamsContract, params).to_h.values
        result = Players::AuthenticateService.call(*authenticate_params)

        response['Content-Type'] = 'application/json'
        if result.success?
          response.status = 200
          result.player.to_json
        else
          response.status = 403
          error_response(result.errors)
        end
      end

      r.post 'admin_authenticate' do
        authenticate_params = validate_with!(AdminAuthenticateParamsContract, params).to_h.values
        result = Players::AdminAuthenticateService.call(*authenticate_params)

        response['Content-Type'] = 'application/json'
        if result.success?
          response.status = 200
          result.player.to_json
        else
          response.status = 403
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
