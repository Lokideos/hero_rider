# frozen_string_literal: true

module Hunters
  class ChangeServicePasswordService
    prepend BasicService

    param :hunter_name
    param :password

    attr_reader :hunter

    def call
      return fail_t!(:missing_password) if password.nil? || password.size.zero?

      @hunter = TrophyHunter.find(name: @hunter_name)

      return fail_t!(:not_found) unless @hunter

      @hunter.update(password: @password)

      valid?(@hunter) ? @hunter : fail_t!(:failure)
    end

    def valid?(hunter)
      hunter.reload.password == @password
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.hunters.change_service_password_service'))
    end
  end
end
