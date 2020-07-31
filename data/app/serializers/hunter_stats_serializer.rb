# frozen_string_literal: true

module HunterStatsSerializer
  module_function

  def serialize(hunters)
    hunters.map do |hunter|
      {
        name: hunter.name,
        active: hunter.active?,
        geared_up: hunter.geared_up?
      }
    end
  end
end
