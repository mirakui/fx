require 'loggable'

module Gena
  class PidFile

    include Loggable

    def initialize(path)
      @path = path
    end

    def read
      return nil unless exist?
      pid = open(@path).read.to_i
      logger.info "Read pid=#{pid} (#{@path})"

      delete_if_already_died(pid)
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

    def exist?
      File.exist?(@path)
    end

    def alive?(pid=nil)
      return false unless (pid ||= read)
      pgid = Process.getpgid(pid)
      logger.debug "alive?: pgid=#{pgid}"
      true
    rescue => e
      logger.debug "alive?: raised #{e.inspect}"
      false
    end

    def delete_if_already_died(pid=nil)
      unless alive?(pid)
        logger.warn "Pid File Exists But Not Alive pid=#{pid} (#{@path})"
        delete
        return nil
      end
      pid
    end

    def kill(sig, pid=nil)
      Process.kill(sig, pid || read)
    end

  end
end
