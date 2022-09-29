class CustomLogger
  @logger = Logging.logger(STDOUT)

  class << self
    def info(message)
      @logger.info message
    end

    def warn(message)
      @logger.warn message
    end
  end
end
