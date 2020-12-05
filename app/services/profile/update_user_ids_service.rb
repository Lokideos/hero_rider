# frozen_string_literal: true

module Profile
  class UpdateUserIdsService
    prepend BasicService

    param :hunter
    option :client, default: proc {
      PsnService::V2::HttpClient.new(url: Settings.psn.v2.profile.url)
    }

    attr_reader :updated_players

    def call
      @hunter.authenticate unless @hunter.access_token.present?

      friends_user_ids =
        @client.request_user_ids(token: @hunter.access_token, user_id: @hunter.trophy_user_id)
      friends_trophy_accounts =
        @client.request_users_info(token: @hunter.access_token, account_ids: friends_user_ids)

      @updated_players = []
      friends_trophy_accounts.each.with_index do |trophy_account, index|
        player = Player.find(Sequel.ilike(:trophy_account, trophy_account))
        next unless player.present?

        @updated_players << player
        player.update(trophy_user_id: friends_user_ids[index])
      end
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.players.admin_authenticate_service'))
    end
  end
end
