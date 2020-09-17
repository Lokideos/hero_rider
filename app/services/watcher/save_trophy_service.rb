# frozen_string_literal: true

module Watcher
  class SaveTrophyService
    prepend BasicService

    PLATINUM_STICKER = 'BQADAgADTwsAAkKvaQABElnJclGri9EC'

    param :player_id
    param :trophy_id
    param :trophy_earning_time
    param :initial_load
    option :player, default: proc { Player.find(id: player_id) }
    option :trophy, default: proc { Trophy.find(id: trophy_id) }

    def call
      # TODO: add service to also add earned date to join table via transaction
      @player.add_trophy(@trophy)
      trophy_acquisition = @player.reload.trophy_acquisitions.find do |acquisition|
        acquisition.trophy_id == @trophy.id
      end
      trophy_acquisition.update(earned_at: @trophy_earning_time)
      return if @initial_load

      Workers::ProcessTrophyTopUpdate.perform_async(@player.id, @trophy.id)

      # TODO: probably should use ruby built-in url generators for this
      link = prepared_link
      message_parts = if @player.trophy_ping_on?
                        ["@#{@player.telegram_username}"]
                      else
                        ['<code>' \
                                  "#{@player.telegram_username}</code>"]
end
      message_parts << "- <a href='#{link}'>#{@trophy.game.title} #{@trophy.game.platform}</a>"

      message = message_parts.join(' ')

      Chat::SendChatMessageService.call(message)
      return unless @trophy.trophy_type == 'platinum'

      Chat::SendStickerService.call(PLATINUM_STICKER)
    end

    private

    # TODO: refactoring needed
    def prepared_link
      "https://#{Settings.fqdn}/trophy?" \
        "player_account=#{CGI.escape(@player.trophy_account)}&" \
        "trophy_title=#{CGI.escape(@trophy.trophy_name)}&" \
        "trophy_description=#{CGI.escape(@trophy.trophy_description)}&" \
        "trophy_type=#{CGI.escape(@trophy.trophy_type)}&" \
        "trophy_rarity=#{CGI.escape(@trophy.trophy_earned_rate)}%25&" \
        "icon_url=#{CGI.escape(@trophy.trophy_icon_url)}&" \
        "game_title=#{CGI.escape(@trophy.game.title)}"
    end
  end
end
