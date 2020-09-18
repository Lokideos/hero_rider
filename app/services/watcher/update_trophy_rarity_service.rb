# frozen_string_literal: true

module Watcher
  class UpdateTrophyRarityService
    prepend BasicService

    param :trophy
    param :trophy_earned_rate
    param :trophy_rare

    def call
      @trophy.update(trophy_earned_rate: @trophy_earned_rate, trophy_rare: @trophy_rare)
    end
  end
end
