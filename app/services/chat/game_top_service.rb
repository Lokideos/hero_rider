# frozen_string_literal: true

module Chat
  class GameTopService
    prepend BasicService

    MAX_NAME_LENGTH = 15
    MAX_PROGRESS_LENGTH = 4
    PLATINUM_EARN_ICON = "\xF0\x9F\x8F\x86"
    FIRST_PLACE_ICON = "\xF0\x9F\xA5\x87"
    SECOND_PLACE_ICON = "\xF0\x9F\xA5\x88"
    THIRD_PLACE_ICON = "\xF0\x9F\xA5\x89"

    param :top

    attr_reader :game_top

    # TODO: Refactoring needed
    def call
      game_top = []
      @top.each do |progress|
        player_name = progress['trophy_account']
        player_progress = progress['progress']
        platinum_trophy = progress['platinum_earning_date'] ? PLATINUM_EARN_ICON : nil
        platinum_placement = progress['platinum_placement']
        placement = platinum_placement.present? ? platinum_placement_icon(platinum_placement) : nil
        player_name = player_name[0..12] + '..' if player_name.length > 13
        game_top << "<code>#{player_name} " + ' ' * (MAX_NAME_LENGTH - player_name.length) +
                    player_progress.to_s +
                    ' ' * (MAX_PROGRESS_LENGTH - player_progress.to_s.length) + '</code>' +
                    platinum_trophy.to_s +
                    placement.to_s
      end

      @game_top = game_top.join("\n")
    end

    private

    def platinum_placement_icon(place)
      case place
      when 1 then FIRST_PLACE_ICON
      when 2 then SECOND_PLACE_ICON
      when 3 then THIRD_PLACE_ICON
      else ''
      end
    end
  end
end
