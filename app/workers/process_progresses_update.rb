# frozen_string_literal: true

module Workers
  class ProcessProgressesUpdate
    include Sidekiq::Worker
    sidekiq_options queue: :trophies, retry: 0, backtrace: 20

    def perform(game_id)
      Watcher::UpdateGameProgressesService.call(game_id: game_id)
    end
  end
end
