# frozen_string_literal: true

class TrophyAcquisition < Sequel::Model
  many_to_one :player
  many_to_one :trophy
end
