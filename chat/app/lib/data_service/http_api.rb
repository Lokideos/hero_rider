# frozen_string_literal: true

require_relative 'http_api/http_games_api'
require_relative 'http_api/http_hunters_api'
require_relative 'http_api/http_players_api'

module DataService
  module HttpApi
    include HttpGamesApi
    include HttpHuntersApi
    include HttpPlayersApi
  end
end
