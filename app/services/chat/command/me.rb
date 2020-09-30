# frozen_string_literal: true

module Chat
  module Command
    class Me
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        result = ::Players::FindPlayerService.call(@command['message']['from']['username'])
        return if result.failure?

        profile = result.player.profile
        player_name = result.player.telegram_username
        trophy_account = result.player.trophy_account
        telegram_name = result.player.telegram_username
        trophy_level = result.player.trophy_level
        level_up_progress = result.player.level_up_progress
        games_count = profile[:games].count
        trophy_total = profile[:trophies][:total].count + profile[:hidden_trophies][:total].count
        uniq_plats = profile[:unique_platinums]
        plat_count = profile[:trophies][:platinum].count
        gold_count = profile[:trophies][:gold].count
        silver_count = profile[:trophies][:silver].count
        bronze_count = profile[:trophies][:bronze].count
        total_count = profile[:trophies][:total].count
        hidden_plat_count = profile[:hidden_trophies][:platinum].count
        hidden_gold_count = profile[:hidden_trophies][:gold].count
        hidden_silver_count = profile[:hidden_trophies][:silver].count
        hidden_bronze_count = profile[:hidden_trophies][:bronze].count
        hidden_total_count = profile[:hidden_trophies][:total].count

        message = ["<b>Профиль игрока #{trophy_account} (@#{telegram_name})</b>"]
        message << "<code>PSN level           #{trophy_level}</code>"
        message << "<code>Level up progress   #{level_up_progress}</code>"
        message << "<code>Количество игр      #{games_count}</code>"
        message << "<code>Всего трофеев       #{trophy_total}</code>"
        message << "<code>Уникальные платины  #{uniq_plats}</code>"
        message << '<code>Вывести платины:</code>'
        message << "/stats_plats_#{telegram_name}"
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
