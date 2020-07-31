# frozen_string_literal: true

module Hunters
  class GetHunterService
    prepend BasicService

    param :hunter_name

    attr_reader :hunter

    def call
      @hunter = TrophyHunter.find(name: @hunter_name)

      valid?(@hunter) ? @hunter : fail_t!(:not_found)
    end

    def valid?(hunter)
      hunter.present?
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.hunters.get_hunter_service'))
    end
  end
end
