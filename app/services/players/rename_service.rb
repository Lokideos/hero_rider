# frozen_string_literal: true

module Players
  class RenameService
    prepend BasicService

    param :username
    param :new_username

    attr_reader :player

    def call
      @player = Player.find(telegram_username: @username)
      return fail_t!(:not_found) unless @player.present?

      return fail_t!(:incorrect_name) unless @new_username.present?

      @player.update(telegram_username: @new_username)

      Player.trophy_top_force_update
      Game.update_all_progress_caches
    end

    def fail_t!(key)
      fail!(I18n.t(key, scope: 'services.players.rename_service'))
    end
  end
end
