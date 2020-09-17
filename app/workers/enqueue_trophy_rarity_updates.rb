# frozen_string_literal: true

module Workers
  class EnqueueTrophyRarityUpdates
    include Sidekiq::Worker
    sidekiq_options queue: :trophies, retry: 0, backtrace: 20

    def perform(game_id, trophies_data)
      trophies_data.each do |trophy_data|
        Workers::ProcessTrophyRarityUpdate.perform_async(game_id, trophy_data)
      end

      Workers::ProcessTopUpdates.perform_async
    end
  end
end
