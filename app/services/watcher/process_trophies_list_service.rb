# frozen_string_literal: true

module Watcher
  class ProcessTrophiesListService
    prepend BasicService

    TROPHY_TYPES = %w[bronze silver gold platinum].freeze
    TIME_TO_FINISH_INITIAL_LOAD = 3600

    param :player_id
    param :game_id
    param :trophy_service_id
    param :initial_load
    option :player, default: proc { Player.find(id: @player_id) }
    option :game, default: proc { Game.find(id: @game_id) }
    option :client, default: proc {
      PsnService::V2::HttpClient.new(url: Settings.psn.v2.trophies.url)
    }

    def call
      hunter_name = nil
      until hunter_name
        hunter_name = RedisDb.redis.smembers('holy_rider:watcher:hunters').find do |name|
          !RedisDb.redis.exists?("holy_rider:watcher:hunters:#{name}:trophy_queue:tainted")
        end
        unless hunter_name
          CustomLogger.info(I18n.t(:all_hunters_tainted, scope: 'logs.services.watcher.process_trophies_list_service'))
          sleep(1)
        end
      end

      RedisDb.redis.setex("holy_rider:watcher:hunters:#{hunter_name}:trophy_queue:tainted",
                          Watcher::DEFAULT_TAINT_TIME - rand(3..5),
                          'tainted')

      token = RedisDb.redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")
      unless token
        hunter = TrophyHunter.find(name: hunter_name)
        hunter.store_access_token(hunter.authenticate)
        token = RedisDb.redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")
      end
      # If player deleted during initial load phase
      return unless @player.present?

      trophies_list = @client.request_game_player_trophies(
        user_id: @player.trophy_user_id, token: token, game_id: @trophy_service_id,
        trophy_service_source: @game.trophy_service_source
      )

      # TODO: here I check for new trophies (typically comes from DLC)
      # TODO: probably should move to separate service altogether
      all_new_trophy_ids = trophies_list.map { |trophy| trophy['trophyId'] }
      all_game_trophy_ids = @game.trophies.map(&:trophy_service_id)
      new_trophy_ids = all_new_trophy_ids - all_game_trophy_ids

      unless new_trophy_ids.empty?
        Watcher::CorrectGameTrophiesService.call(player: @player, token: token, game: @game,
                                                 new_trophy_ids: new_trophy_ids)
      end

      earned_trophies = trophies_list.select { |trophy| trophy['earned'] }

      if @initial_load
        RedisDb.redis.setex(
          "holy_rider:watcher:players:initial_load:#{@player.trophy_account}:trophy_count",
          TIME_TO_FINISH_INITIAL_LOAD,
          'initial_load'
        )
      end

      earned_trophies_ids = earned_trophies.map { |trophy| trophy['trophyId'] }
      player_trophies = @player.trophies.select { |trophy| trophy.game_id == @game.id }

      new_earned_trophies_ids = earned_trophies_ids - player_trophies.map(&:trophy_service_id)

      # TODO: get rid of multiline block chaining
      earned_trophies_data = earned_trophies.select do |trophy|
        new_earned_trophies_ids.include? trophy['trophyId']
      end.map do |trophy|
        {
          trophy_service_id: trophy['trophyId'],
          trophy_earned_rate: trophy['trophyEarnedRate'],
          trophy_rare: trophy['trophyRare'],
          earned_at: trophy['earnedDateTime']
        }
      end

      # Update rarity for current trophy, then enqueue current trophy worker
      unless @initial_load
        earned_trophies_data.each do |trophy_data|
          trophy = @game.trophies.find do |trophy|
            trophy.trophy_service_id == trophy_data[:trophy_service_id]
          end
          Watcher::UpdateTrophyRarityService.call(trophy,
                                                  trophy_data[:trophy_earned_rate],
                                                  trophy_data[:trophy_rare])
        end
      end

      # TODO: find in Sequel better method to do this
      new_earned_trophies = new_earned_trophies_ids.map do |trophy_id|
        @game.trophies.find { |trophy| trophy.trophy_service_id == trophy_id }
      end.group_by(&:trophy_type)
      sorted_new_trophies = TROPHY_TYPES.flat_map do |trophy_type|
        new_earned_trophies[trophy_type]
      end.compact

      sorted_new_trophies.each do |trophy|
        trophy_earning_time = earned_trophies_data.find do |trophy_date|
          trophy_date[:trophy_service_id] == trophy.trophy_service_id
        end[:earned_at]

        if @initial_load
          Workers::InitialProcessTrophy.perform_async(@player.id, trophy.id, trophy_earning_time,
                                                      @initial_load)
          next
        end

        Workers::ProcessTrophy.perform_async(@player.id, trophy.id, trophy_earning_time,
                                             @initial_load)
      end

      # Then update rarity for other trophies
      unless @initial_load
        not_earned_trophies_ids = all_new_trophy_ids - new_earned_trophies_ids
        not_earned_trophies_data = trophies_list.select do |trophy|
          not_earned_trophies_ids.include? trophy['trophyId']
        end.map do |trophy|
          {
            trophy_service_id: trophy['trophyId'],
            trophy_earned_rate: trophy['trophyEarnedRate'],
            trophy_rare: trophy['trophyRare']
          }
        end

        Workers::EnqueueTrophyRarityUpdates.perform_async(@game.id, not_earned_trophies_data)
      end

      RedisDb.redis.srem(
        "holy_rider:watcher:players:initial_load:#{@player.trophy_account}:trophies",
        @trophy_service_id
      )

      if RedisDb.redis.scard(
        "holy_rider:watcher:players:initial_load:#{@player.trophy_account}:trophies"
      ).zero?
        RedisDb.redis.del("holy_rider:watcher:players:initial_load:#{@player.trophy_account}")
        # TODO: update only game tops of this player instead of all game tops
        Workers::ProcessSingleGameTopUpdate.perform_async(@game_id)
      end
    end
  end
end
