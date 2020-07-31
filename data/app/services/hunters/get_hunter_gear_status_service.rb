# frozen_string_literal: true

module Hunters
  class GetHunterGearStatusService
    prepend BasicService

    param :hunter_name

    attr_reader :hunter

    def call
      @hunter = TrophyHunter.find(name: @hunter_name)

      return fail_t!(:not_found) unless @hunter

      valid?(@hunter) ? @hunter : fail_t!(:failure)
    end

    def valid?(hunter)
      hunter.geared_up?
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.hunters.get_hunter_gear_status_service'))
    end
  end
end
