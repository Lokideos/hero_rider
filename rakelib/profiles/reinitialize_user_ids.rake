# frozen_string_literal: true

namespace :profiles do
  desc 'Reinitialize user_ids for users (users must be friends)'
  task reinitialize: :settings do
    require_relative '../../config/environment'

    Profile::UpdateUserIdsService.call(TrophyHunter.first)
  end
end
