# frozen_string_literal: true

module Watcher
  extend self

  DEFAULT_TAINT_TIME = 10

  def prepare
    RedisDb.redis.del('holy_rider:watcher:players')
    RedisDb.redis.del('holy_rider:watcher:hunters')
    RedisDb.redis.del('holy_rider:watcher:hunters:tainted')
  end

  def interaction
    hunters = TrophyHunter.active_hunters
    hunter_names = hunters.map(&:name)
    if hunter_names.empty?
      p 'There are no hunters'
      sleep(1)
      return
    end

    RedisDb.redis.sadd('holy_rider:watcher:hunters', hunter_names)

    active_trophy_accounts = Player.active_trophy_accounts
    if active_trophy_accounts.empty?
      p 'There are no players'
      sleep(1)
      return
    end

    # TODO: add user_ids and iterate other them; get them(!)
    RedisDb.redis.sadd('holy_rider:watcher:players', active_trophy_accounts)

    RedisDb.redis.smembers('holy_rider:watcher:players').each do |player|
      if RedisDb.redis.get("holy_rider:watcher:players:initial_load:#{player}") == 'in_progress'
        p "Watcher: player #{player} is still in the initial load phase."
        sleep(0.2)
        next
      end

      hunter_name = nil
      until hunter_name
        hunter_name = RedisDb.redis.smembers('holy_rider:watcher:hunters').find do |name|
          !RedisDb.redis.get("holy_rider:watcher:hunters:#{name}:game_queue:tainted")
        end

        unless hunter_name
          p 'Watcher: all hunters are tainted at the moment'
          sleep(1)
        end
      end

      RedisDb.redis.setex("holy_rider:watcher:hunters:#{hunter_name}:game_queue:tainted",
                          DEFAULT_TAINT_TIME + rand(1..3),
                          'tainted')

      if RedisDb.redis.get("holy_rider:watcher:players:initial_load:#{player}")
        RedisDb.redis.set("holy_rider:watcher:players:initial_load:#{player}", 'in_progress')
      end

      unless RedisDb.redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")
        hunter = TrophyHunter.find(name: hunter_name)
        hunter.store_access_token(hunter.authenticate)
      end

      token = RedisDb.redis.get("holy_rider:trophy_hunter:#{hunter_name}:access_token")
      # TODO: get user_id before this
      user_id = RedisDb.redis.get("holy_rider:watcher:players:#{player}:user_id")
      psn_updates = Psn::TrophyUpdatesService.call(player_name: player, user_id: user_id,
                                                   token: token).result

      if psn_updates.dig('error', 'message') == 'Access token required'
        p 'Watcher: Refresh token has expired'
        sleep(0.2)
        return
      end

      Watcher::NewGamesService.call(player_name: player, token: token, updates: psn_updates)
      Watcher::LinkGamesService.call(player_name: player, updates: psn_updates)
      Watcher::NewTrophiesService.call(player_name: player, updates: psn_updates,
                                       hunter_name: hunter_name)
      p "Watcher: player #{player} status checked"

      Screenshots::ProcessScreenshotsService.call(token: token)
      p 'Watcher: new screenshots processed'
    end

    p 'Watcher: all players checked'
  end
end
