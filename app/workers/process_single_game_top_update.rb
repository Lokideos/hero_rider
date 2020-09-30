# frozen_string_literal: true

module Workers
  class ProcessSingleGameTopUpdate
    include Sidekiq::Worker
    sidekiq_options queue: :commands, retry: 0, backtrace: 20

    # TODO: move logic to service and update only needed game tops
    def perform(game_id)
      Game.store_game_top(Game.find(id: game_id))
    end
  end
end
