# frozen_string_literal: true

module Chat
  module Command
    class Top
      prepend BasicService

      MAX_NAME_LENGTH = 15
      MAX_PLACEMENT_LENGTH = 3

      param :command
      param :message_type

      attr_reader :message

      # TODO: refactoring needed
      def call
        message = ["<b>#{I18n.t(:header, scope: 'services.command_service.top')}</b>"]
        Player.trophy_top.each_with_index do |player_trophies, index|
          name = player_trophies[:telegram_username]
          name = name[0..12] + '..' if name.length > 15
          placement = (index + 1).to_s
          message << "<code>#{placement}" +
                     ' ' * (MAX_PLACEMENT_LENGTH - placement.length) +
                     name +
                     ' ' * (MAX_NAME_LENGTH - name.length) +
                     " #{player_trophies[:points]}</code>"
        end

        @message = [message.join("\n")]
      end
    end
  end
end
