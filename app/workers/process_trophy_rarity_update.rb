# frozen_string_literal: true

module Workers
  class ProcessTrophyRarityUpdate
    include Sidekiq::Worker
    sidekiq_options queue: :trophies, retry: 0, backtrace: 20

    def perform(game_id, trophy_data)
      trophy = Game.find(id: game_id).trophies.find do |trophy|
        trophy.trophy_service_id == trophy_data['trophy_service_id']
      end

      Watcher::UpdateTrophyRarityService.call(trophy, trophy_data['trophy_earned_rate'],
                                              trophy_data['trophy_rare'])
    end
  end
end
