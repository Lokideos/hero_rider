# frozen_string_literal: true

module Screenshots
  class DownloadScreenshotService
    prepend BasicService

    option :message
    option :token
    option :sender_name
    option :image_url, default: proc { @message['messageEventDetail']['attachedMediaPath'] }
    option :client, default: proc { PsnService::V1::HttpClient.new(url: @image_url) }

    def call
      image_data = @client.download_image_data(token: @token)
      return if image_data.nil?

      FileUtils.mkdir('screenshots') unless Dir.exist? 'screenshots'

      filename = "#{SecureRandom.uuid}.jpeg"
      File.write("screenshots/#{filename}", image_data)

      Workers::ProcessImageUpload.perform_async(@sender_name, filename)
    end
  end
end
