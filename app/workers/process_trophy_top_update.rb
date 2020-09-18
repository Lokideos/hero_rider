# frozen_string_literal: true

module Workers
  class ProcessTrophyTopUpdate
    include Sidekiq::Worker
    sidekiq_options queue: :trophies, retry: 0, backtrace: 20

    def perform(player_id, trophy_id)
      Watcher::UpdateTrophyTopService.call(player_id: player_id, trophy_id: trophy_id)
    end
  end
end
