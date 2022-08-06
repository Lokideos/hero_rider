# frozen_string_literal: true

module ResponsibleForRepairs
  class CreateService
    prepend BasicService

    param :username

    attr_reader :responsible_for_repair

    def call
      @player = Player.find(telegram_username: @username)
      return fail_t!(:not_found) unless @player.present?

      @responsible_for_repair = ResponsibleForRepair.find(player_id: @player.id) ||
                                ResponsibleForRepair.new(player_id: @player.id)
      @responsible_for_repair.save

      if @responsible_for_repair.valid?
        @responsible_for_repair.save
      else
        fail!(@responsible_for_repair.errors)
      end
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.responsible_for_repairs.create_service'))
    end
  end
end
