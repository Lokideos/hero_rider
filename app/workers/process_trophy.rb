# frozen_string_literal: true

module Workers
  class ProcessTrophy
    include Sidekiq::Worker
    sidekiq_options queue: :trophies, retry: 0, backtrace: 20

    def perform(player_id, trophy_id, trophy_earning_time, initial_load)
      Watcher::SaveTrophyService.call(player_id, trophy_id, trophy_earning_time, initial_load)
    end
  end
end
