# frozen_string_literal: true

module Chat
  module Command
    class HunterStats
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        telegram_username = @command[@message_type]['from']['username']
        result = RiderData::AuthenticateService.call(telegram_username, admin: true)
        return unless result.success?

        result = RiderData::Hunters::GetHuntersService.call
        return [I18n.t(:failure, scope: 'services.command_service.hunter_stats')] if result.failure?

        message = []
        message << "  Name     Active     Geared\n"
        result.hunters.each_with_index do |hunter, index|
          message <<
            "#{index + 1}. #{hunter['name']}, #{hunter['active']}, #{hunter['geared_up']}\n"
        end

        @message = [message.join]
      end
    end
  end
end
