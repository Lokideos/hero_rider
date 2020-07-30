# frozen_string_literal: true

module Chat
  module Command
    class Stats
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        text = @command[@message_type]['text']
        player_name = text.include?('@') ? text.split(' ')[1][1..] : text.split(' ')[1]
        result = RiderData::PlayerInfoService.call(player_name)
        return @message = ['Игрок не найден'] if result.failure?

        profile = result.profile
        player_name = profile['telegram_name']
        trophy_account = profile['trophy_account']
        telegram_name = profile['telegram_name']
        trophy_level = profile['trophy_level']
        level_up_progress = profile['level_up_progress']
        games_count = profile['games_count']
        trophy_total = profile['trophy_total']
        uniq_plats = profile['uniq_plats']
        plat_count = profile['trophies']['platinum']
        gold_count = profile['trophies']['gold']
        silver_count = profile['trophies']['silver']
        bronze_count = profile['trophies']['bronze']
        total_count = profile['trophies']['total']
        hidden_plat_count = profile['hidden_trophies']['platinum']
        hidden_gold_count = profile['hidden_trophies']['gold']
        hidden_silver_count = profile['hidden_trophies']['silver']
        hidden_bronze_count = profile['hidden_trophies']['bronze']
        hidden_total_count = profile['hidden_trophies']['total']

        message = ["<b>Профиль игрока #{trophy_account} (@#{telegram_name})</b>"]
        message << "<code>PSN level           #{trophy_level}</code>"
        message << "<code>Level up progress   #{level_up_progress}</code>"
        message << "<code>Количество игр      #{games_count}</code>"
        message << "<code>Всего трофеев       #{trophy_total}</code>"
        message << "<code>Уникальные платины  #{uniq_plats}</code>"
        message << "<b>\nТрофеи:</b>"
        message << "<code>Платина             #{plat_count}</code>"
        message << "<code>Золото              #{gold_count}</code>"
        message << "<code>Серебро             #{silver_count}</code>"
        message << "<code>Бронза              #{bronze_count}</code>"
        message << "<code>Всего               #{total_count}</code>"
        if hidden_total_count.zero?
          message << "\n<b>Скрытые трофеи:</b>  #{player_name} скрывать нечего!"
        else
          message << "<b>\nСкрытые трофеи:</b>"
          message << "<code>Платина             #{hidden_plat_count}</code>"
          message << "<code>Золото              #{hidden_gold_count}</code>"
          message << "<code>Серебро             #{hidden_silver_count}</code>"
          message << "<code>Бронза              #{hidden_bronze_count}</code>"
          message << "<code>Всего               #{hidden_total_count}</code>"
        end

        @message = [message.join("\n")]
      end
    end
  end
end
