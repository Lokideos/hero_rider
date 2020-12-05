# frozen_string_literal: true

module Players
  class BefriendAllService
    prepend BasicService

    attr_reader :player

    def call
      players_to_update = Player.where(on_watch: true, trophy_user_id: nil)

      hunter_name = nil
      until hunter_name
        hunter_name = RedisDb.redis.smembers('holy_rider:watcher:hunters').find do |name|
          !RedisDb.redis.exists?("holy_rider:watcher:hunters:#{name}:trophy_queue:tainted")
        end
        unless hunter_name
          p 'Watcher: All hunters are tainted. Waiting...'
          sleep(1)
        end
      end

      RedisDb.redis.setex("holy_rider:watcher:hunters:#{hunter_name}:trophy_queue:tainted",
                          Watcher::DEFAULT_TAINT_TIME - rand(3..5),
                          'tainted')
      hunter = TrophyHunter.find(name: hunter_name)

      players_to_update.each do |player|
        Profile::FriendRequestService(hunter, player.trophy_account)
        sleep(0.5)
      end
    end
  end
end
