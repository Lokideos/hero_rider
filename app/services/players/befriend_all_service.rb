# frozen_string_literal: true

module Players
  class BefriendAllService
    prepend BasicService

    def call
      players_to_update = Player.where(on_watch: true, trophy_user_id: nil).all

      players_to_update.each do |player|
        Profile::FriendRequestService.call(TrophyHunter.first, player.trophy_account)
        sleep(0.5)
      end
    end
  end
end
