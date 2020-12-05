# frozen_string_literal: true

module Players
  class CreateService
    prepend BasicService

    param :username
    param :trophy_account

    attr_reader :player

    def call
      @player = Player.new(telegram_username: @username)
      if @trophy_account.present?
        @player.trophy_account = @trophy_account
        @player.message_thread_name = @trophy_account
        @player.on_watch = true
        RedisDb.redis.set("holy_rider:watcher:players:initial_load:#{@trophy_account}", 'initial')
      end

      if @player.valid?
        @player.save
      else
        fail!(@player.errors)
      end
    end
  end
end
