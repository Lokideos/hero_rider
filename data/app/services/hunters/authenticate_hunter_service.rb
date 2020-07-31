# frozen_string_literal: true

module Hunters
  class AuthenticateHunterService
    prepend BasicService

    param :hunter_name
    param :sso_cookie

    attr_reader :hunter

    def call
      @hunter = TrophyHunter.find(name: @hunter_name)
      return fail_t!(:not_found) unless @hunter

      @hunter.full_authentication(@sso_cookie)

      valid?(@hunter) ? @hunter : fail_t!(:failure)
    end

    def valid?(hunter)
      hunter.geared_up?
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.hunters.authenticate_hunter_service', name: @hunter.name))
    end
  end
end
