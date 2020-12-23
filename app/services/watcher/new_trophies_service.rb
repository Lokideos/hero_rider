# frozen_string_literal: true

module Watcher
  class NewTrophiesService
    prepend BasicService

    SECONDS_IN_DAY = 86_400

    option :player_name
    option :updates
    option :hunter_name
    option :player, default: proc { Player.find(trophy_account: @player_name) }

    def call
      # TODO: find better name for fuck sake
      games_trophy_progresses = @updates['trophyTitles'].map do |game|
        {
          trophy_service_id: game['npCommunicationId'],
          progress: game['progress'],
          last_updated_date: game['lastUpdatedDateTime']
        }
      end

      unless player_in_initial_load?(@player_name)
        service_ids = games_trophy_progresses.map { |progress| progress[:trophy_service_id] }
        current_game_status_dates = Player.last_updated_game_ids(@player_name, service_ids)
                                          .map do |date|
          date&.utc
        end.compact.sort
        psn_game_status_dates = games_trophy_progresses.map do |progress|
          progress[:last_updated_date]
        end
        prepared_psn_dates = psn_game_status_dates.map { |date| Time.parse(date) }
        if prepared_psn_dates.all? { |date| current_game_status_dates.include? date }
          unless hidden_trophies_checked_today?(@player_name)
            Watcher::AddHiddenTrophiesService.call(player_name: @player_name,
                                                   hunter_name: @hunter_name)
            RedisDb.redis.setex("holy_rider:watcher:players:hidden_check:#{@player_name}",
                                SECONDS_IN_DAY,
                                'checked')
          end
          return
        end
      end

      games_trophy_progresses.each do |trophy_progress|
        game = Game.find(trophy_service_id: trophy_progress[:trophy_service_id])
        game_acquistion = game.game_acquisitions.find do |acquisition|
          acquisition.player_id == @player.id
        end

        trophy_service_update_date = Time.parse(trophy_progress[:last_updated_date])
        watcher_update_date = game_acquistion.last_updated_date
        next if trophy_service_update_date == watcher_update_date

        game_acquistion.update(progress: trophy_progress[:progress],
                               last_updated_date: trophy_progress[:last_updated_date])

        if player_in_initial_load?(@player_name)
          process_initial_trophies_list(@player, trophy_progress, game)

          next
        end

        process_regular_trophies_list(@player, trophy_progress, game)
      end
    end

    private

    def process_initial_trophies_list(player, trophy_progress, game)
      RedisDb.redis.sadd(
        "holy_rider:watcher:players:initial_load:#{player.trophy_account}:trophies",
        trophy_progress[:trophy_service_id]
      )
      Workers::InitialProcessTrophiesList.perform_async(
        player.id,
        game.id,
        trophy_progress[:trophy_service_id],
        player_in_initial_load?(@player_name)
      )
    end

    def process_regular_trophies_list(player, trophy_progress, game)
      Workers::ProcessTrophiesList.perform_async(
        player.id,
        game.id,
        trophy_progress[:trophy_service_id],
        player_in_initial_load?(@player_name)
      )
    end

    def player_in_initial_load?(player_name)
      RedisDb.redis.exists?("holy_rider:watcher:players:initial_load:#{player_name}")
    end

    def hidden_trophies_checked_today?(player_name)
      RedisDb.redis.exists?("holy_rider:watcher:players:hidden_check:#{player_name}")
    end
  end
end
