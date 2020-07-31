# frozen_string_literal: true

module Chat
  module Command
    class Help
      prepend BasicService

      param :command
      param :message_type

      attr_reader :message

      def call
        message = ['Список команд:']
        message << '/last - показывает топ по последней игре, по которой был получен трофей'
        message << '/top - выводит топ по трофеям среди игроков'
        message << '/top_rare - выводит топ по редким трофеям среди игроков'
        message << '/me - выводит информацию о запросившем игроке'
        message << '/stats [@telegram_name] - выводит информацию об игроке [telegram_name]'
        message << '/find [game_title] - поиск одной игры'
        message << '/games [game_title] - поиск нескольких игр'
        message << '/trophy_ping_on - включает оповещения о новых трофеях'
        message << '/trophy_ping_off - выключает оповещения о новых трофеях'
        message << '/man_find - выводит мануал по работе с комадной <code>/find</code>'
        message << '/man_games - выводит мануал по работе с комадной <code>/games</code>'
        message << '/man_screenshot - выводит мануал по загрузке скриншотов'

        telegram_username = @command[@message_type]['from']['username']
        result = ::Players::AdminAuthenticateService.call(telegram_username)
        return @message = [message.join("\n")] unless result.success?

        message << '/hunter_stats - показывает текущих охотников за трофеями'
        message << '/hunter_credentials [hunter_name] - показывает email и пароль охотника'
        message << '/hunter_gear_up [npsso_cookie] - обновляет refresh token'
        message << '/hunter_gear_status [hunter_name] - отображает статус токена охотника'
        message << '/hunter_activate [hunter_name] - охотник начинает обращаться в PSN'
        message << '/hunter_deactivate [hunter_name] - охотник перестает обращаться в PSN'
        message << '/top_players_force_update - переформирует кэш топа трофеев игроков'
        message << '/top_games_force_update - переформирует кэш топов игр - может занять ' \
                   'длительное время'
        message << '/player_add [player_name] [*player_account] - добавляет игрока и ' \
                   'связывает его с PSN аккаунтом(опционально)'
        message << '/player_link [player_name] [player_account] - связывает игрока с PSN ' \
                   ' аккаунтом'
        message << '/player_reload [player_name] - перезагружает игры и трофеи игрока'
        message << '/player_watch_on [player_name] - начинает отслеживать трофеи игрока'
        message << '/player_watch_off [player_name] - перестает отслеживать трофеи игрока'
        message << '/player_rename [current_player_name] [new_player_name] - меняет имя игрока ' \
                   'в Телеграме'
        message << '/player_destroy [player_name] - удаляет игрока и всю информацию о нем'
        message << '/players - показывает список зарегистрированных игроков'

        @message = [message.join("\n")]
      end
    end
  end
end
