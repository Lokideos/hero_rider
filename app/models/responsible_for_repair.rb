# frozen_string_literal: true

class ResponsibleForRepair < Sequel::Model
  many_to_one :player
end
