# frozen_string_literal: true

module RiderData
  class AuthenticateService
    prepend BasicService

    param :telegram_username
    option :client, default: proc { DataService::HttpClient.new }
    option :admin, default: proc { false }

    def call
      result = if @admin
                 @client.admin_authenticate(@telegram_username)
               else
                 @client.authenticate(@telegram_username)
               end

      valid?(result) ? result : fail_t!(:unauthorized)
    end

    def valid?(result)
      result[:status] == 200
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.rider_data.authenticate_service'))
    end
  end
end
