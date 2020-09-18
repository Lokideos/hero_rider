# frozen_string_literal: true

module Workers
  class ProcessTrophiesList
    include Sidekiq::Worker
    sidekiq_options queue: :trophies, retry: 0, backtrace: 20

    def perform(player, game, game_id, initial_load)
      Watcher::ProcessTrophiesListService.call(player, game, game_id, initial_load)
    end
  end
end
