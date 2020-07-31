# frozen_string_literal: true

module Hunters
  class GetAllHuntersService
    prepend BasicService

    attr_reader :hunters

    def call
      @hunters = TrophyHunter.all

      valid?(@hunters) ? @hunters : fail_t!(:not_found)
    end

    def valid?(hunters)
      hunters.is_a? Array
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.hunters.get_hunter_service'))
    end
  end
end
