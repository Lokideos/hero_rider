# frozen_string_literal: true

module Profile
  class DeleteFriendService
    prepend BasicService

    param :hunter
    param :trophy_user_id
    option :client, default: proc {
      PsnService::V2::HttpClient.new(url: Settings.psn.v2.profile.url)
    }

    def call
      @hunter.authenticate unless @hunter.access_token.present?

      result = @client.delete_friend(token: @hunter.access_token, user_id: @trophy_user_id)

      fail_t!(:failure) unless valid_response?(result)
    end

    def valid_response?(result)
      result[:status] == 204
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.profile.delete_friend_service'))
    end
  end
end
