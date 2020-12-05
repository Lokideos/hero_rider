# frozen_string_literal: true

module Chat
  class CommandService
    prepend BasicService

    CACHED_GAMES = (1..10).to_a.map(&:to_s).freeze

    ADMIN_COMMANDS = %w[
      hunter_credentials
      hunter_stats
      hunter_gear_status
      hunter_gear_up
      hunter_activate
      hunter_deactivate
      player_add
      player_link
      players
      player_reload
      player_watch_on
      player_watch_off
      player_rename
      player_destroy
      player_befriend_all
      top_players_force_update
      top_games_force_update
    ].freeze

    COMMON_COMMANDS = %w[
      help
      find
      games
      top
      top_rare
      me
      me_plats
      stats
      stats_plats
      trophy_ping_on
      trophy_ping_off
      last
      man_find
      man_games
      man_screenshot
    ].concat(CACHED_GAMES).freeze

    CUSTOM_COMMANDS = %w[stats_plats_].freeze

    EXPIRE_COMMANDS = %w[games].freeze

    param :command
    param :message_type
    option :allowed_public_chat_ids, default: proc {
      [Settings.telegram.admin_chat_id, Settings.telegram.main_chat_id]
    }
    option :admin_chat_id, default: proc { Settings.telegram.admin_chat_id }
    option :ps_chat_id, default: proc { Settings.telegram.main_chat_id }
    option :current_chat_id, default: proc { @command[@message_type]['chat']['id'] }
    option :chat_type, default: proc { @command[@message_type]['chat']['type'] }

    # TODO: combine multiple guard clauses to separate checks in methods
    def call
      return unless @allowed_public_chat_ids.include?(@current_chat_id) || @chat_type == 'private'

      result = Players::AuthenticateService.call(@command[@message_type]['from']['username'])

      if result.failure?
        send_unauthorized_message
        return
      end

      command = @command[@message_type]['text'].split(' ').first[1..]
      if command.include? '@'
        return unless command.include? Settings.telegram.bot_name

        command = command.split('@').first
      end
      unless (COMMON_COMMANDS + ADMIN_COMMANDS).include?(command) ||
             CUSTOM_COMMANDS.any? { |custom_command| command.match?(/^#{custom_command}.*/) }
        return
      end

      if ADMIN_COMMANDS.include? command
        return unless @current_chat_id == @admin_chat_id
      end

      command = 'get_game_from_cache' if CACHED_GAMES.include? command
      command = 'stats_plats_from_profile' if command.match?(/^stats_plats_.*$/)
      messages = Kernel.const_get("Chat::Command::#{prepared_command(command)}")
                       .call(@command, @message_type).message

      chat_id = ADMIN_COMMANDS.include?(command) ? @admin_chat_id : @current_chat_id

      to_delete = EXPIRE_COMMANDS.include?(command) ? true : false

      messages&.each do |message|
        Chat::SendChatMessageService.call(message, to_delete, chat_id)
      end
    end

    private

    def send_unauthorized_message
      message = I18n.t(:unauthorized, scope: 'chat')
      Chat::SendChatMessageService.call(chat_id: @current_chat_id, message: message)
    end

    def prepared_command(command)
      command.split('_').map(&:capitalize).join
    end
  end
end
