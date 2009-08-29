require 'logger'

module Gena

  module Loggable

    def logger
      LoggerHolder.logger
    end

    def logger=(logger)
      LoggerHolder.logger = logger
    end

  end

  class LoggerHolder
    
    def self.logger
      unless defined? @logger
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::DEBUG
      end
      @logger
    end

    def self.logger=(logger)
      @logger = logger
    end
  end

end
