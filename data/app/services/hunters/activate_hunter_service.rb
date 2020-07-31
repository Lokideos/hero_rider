# frozen_string_literal: true

module Hunters
  class ActivateHunterService
    prepend BasicService

    param :hunter_name

    attr_reader :hunter

    def call
      @hunter = TrophyHunter.find(name: @hunter_name)

      return fail_t!(:not_found) unless @hunter

      @hunter.activate

      valid?(@hunter) ? @hunter : fail_t!(:failure)
    end

    def valid?(hunter)
      hunter.active?
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.hunters.activate_hunter_service'))
    end
  end
end
