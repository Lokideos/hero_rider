# frozen_string_literal: true

module Workers
  class InitialProcessTrophy
    include Sidekiq::Worker
    sidekiq_options queue: :initial_user_data_load, retry: 0, backtrace: 20

    def perform(player_id, trophy_id, trophy_earning_time, initial_load)
      Watcher::SaveTrophyService.call(player_id, trophy_id, trophy_earning_time, initial_load)
    end
  end
end
