require 'loggable'

module Gena
  class PidFile

    include Loggable

    def initialize(path)
      @path = path
    end

    def read
      return nil unless File.exist?(@path)
      pid = open(@path).read.to_i
      logger.info "Read pid=#{pid} (#{@path})"
      pid
    end

    def write(pid=$$)
      open(@path, 'w') do |f|
        f.write(pid)
        logger.info "Wrote pid=#{pid} (#{@path})"
      end
    end

    def delete
      File.delete(@path)
      logger.info "Deleted pid (#{@path})"
    end

  end
end
