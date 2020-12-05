# frozen_string_literal: true

module Profile
  class FriendRequestService
    prepend BasicService

    param :hunter
    param :trophy_account
    option :client, default: proc {
      PsnService::V2::HttpClient.new(url: Settings.psn.v2.profile.url)
    }

    def call
      @hunter.authenticate unless @hunter.access_token.present?

      friend_user_id = @client.search_for_user_id(token: @hunter.access_token,
                                                  trophy_account: @trophy_account)
      result = @client.add_friend(token: @hunter.access_token, user_id: friend_user_id)

      fail_t!(:failure) unless valid_response?(result)
    end

    def valid_response?(result)
      result[:status] == 204
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.profile.friend_request_service'))
    end
  end
end
