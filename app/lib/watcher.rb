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


    active_trophy_accounts = Player.active_trophy_accounts.select do |player|
      player.trophy_user_id.present?
    end
    on_watch_accounts = Player.active_trophy_accounts
    unless on_watch_accounts.size ==  active_trophy_accounts.size
      Profile::UpdateUserIdsService.call(TrophyHunter.first)
    end

    if active_trophy_accounts.empty?
      p 'There are no active players with trophy_user_id'
      sleep(1)
      return
    end

    RedisDb.redis.del('holy_rider:watcher:players')
    RedisDb.redis.sadd('holy_rider:watcher:players', active_trophy_accounts.map(&:trophy_account))
    active_trophy_accounts.each do |player|
      RedisDb.redis.set("holy_rider:watcher:players:#{player.trophy_account}:trophy_user_id",
                        player.trophy_user_id)
    end

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
      user_id = RedisDb.redis.get("holy_rider:watcher:players:#{player}:trophy_user_id")
      psn_updates = Psn::TrophyUpdatesService.call(player_name: player, user_id: user_id,
                                                   token: token).result

      if psn_updates[:status] == 403 && psn_updates[:body] == 'Access Denied'
        message = "Игрок #{player} запретил доступ к своим трофеям."
        Chat::SendChatMessageService.new(message, chat_id: Settings.telegram.admin_chat_id).call
        next
      end

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
