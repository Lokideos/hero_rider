# frozen_string_literal: true

module TelegramService
  module HttpApi
    def receive_updates(chat_id:)
      response = connection.get('getUpdates') do |request|
        offset_value = RedisDb.redis.get('holy_rider:telegram:offset')
        request.body = { chat_id: chat_id, offset: offset_value || '' }
      end

      updates = response.body
      unless updates['result'].empty?
        last_update_id = updates['result'].last['update_id']
        RedisDb.redis.set('holy_rider:telegram:offset', last_update_id)
      end

      updates
    end

    def send_message(chat_id:, message:)
      response = connection.post('sendMessage') do |request|
        request.body = { chat_id: chat_id, text: message, parse_mode: 'html' }
      end

      if response.status == 429
        sleep_increment = 0
        until response.status != 429
          CustomLogger.warn(I18n.t(:too_many_requests, scope: 'logs.lib.telegram_service.http_api'))
          sleep_increment += 1
          sleep(sleep_increment)
          response = connection.post('sendMessage') do |request|
            request.body = { chat_id: chat_id, text: message, parse_mode: 'html' }
          end
        end
      end

      response
    end

    def delete_message(chat_id:, message_id:)
      connection.post('deleteMessage') do |request|
        request.body = { chat_id: chat_id, message_id: message_id }
      end
    end

    def send_sticker(chat_id:, sticker:)
      response = connection.post('sendSticker') do |request|
        request.body = { chat_id: chat_id, sticker: sticker }
      end

      if response.status == 429
        sleep_increment = 0
        until response.status != 429
          CustomLogger.warn(I18n.t(:too_many_requests, scope: 'logs.lib.telegram_service.http_api'))
          sleep_increment += 1
          sleep(sleep_increment)
          response = connection.post('sendSticker') do |request|
            request.body = { chat_id: chat_id, sticker: sticker }
          end
        end
      end

      response
    end

    def send_image(chat_id:, filepath:, caption: '')
      payload = {
        chat_id: chat_id,
        photo: Faraday::UploadIO.new(File.open(filepath), 'image/jpeg'),
        caption: caption,
        parse_mode: 'html'
      }

      connection.post('sendPhoto', payload) do |request|
        request.headers['Content-Type'] = 'multipart/form-data'
      end
    end
  end
end
