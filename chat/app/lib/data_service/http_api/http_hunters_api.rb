# frozen_string_literal: true

module DataService
  module HttpApi
    module HttpHuntersApi
      def activate_hunter(hunter_name)
        response = connection.post('hunters/activate_hunter') do |request|
          request.body = { hunter_name: hunter_name }
        end

        { status: response.status, body: response.body }
      end

      def deactivate_hunter(hunter_name)
        response = connection.post('hunters/deactivate_hunter') do |request|
          request.body = { hunter_name: hunter_name }
        end

        { status: response.status, body: response.body }
      end

      def request_hunter_data(hunter_name)
        response = connection.get('hunters/hunter') do |request|
          request.body = { hunter_name: hunter_name }
        end

        { status: response.status, body: response.body }
      end

      def request_hunters_data
        response = connection.get('hunters/stats')

        { status: response.status, body: response.body }
      end

      def hunter_gear_status(hunter_name)
        response = connection.get('hunters/hunter_gear_status') do |request|
          request.body = { hunter_name: hunter_name }
        end

        { status: response.status, body: response.body }
      end

      def authenticate_hunter(hunter_name, sso_cookie)
        response = connection.get('hunters/authenticate') do |request|
          request.body = { hunter_name: hunter_name, sso_cookie: sso_cookie }
        end

        { status: response.status, body: response.body }
      end
    end
  end
end
