require 'pid_file'

module Gena

  class Daemon

    include Loggable

    attr_accessor :pid_file

    def initialize(daemon_name, pid_file_path)
      @daemon_name = daemon_name
      @pid_file = PidFile.new(pid_file_path)
      #@pid_file = PidFile.new(File.join(File.dirname(__FILE__), '..', 'log', "#{@daemon_name}.pid"))
    end

    def start
      # FIXME
      # @pid_file.logger = logger
      # http://snippets.dzone.com/posts/show/2265
      fork do
        Process.setsid
        exit if fork
        STDIN.reopen "/dev/null"
        STDOUT.reopen "/dev/null", "a"
        STDERR.reopen STDOUT

        $PROGRAM_NAME = @daemon_name

        logger.info "Daemon #{@daemon_name} Started ##{$$}"
        @pid_file.write
        Signal.trap(:TERM) do
          trapped(:TERM)
        end

        run

        @pid_file.delete
        logger.info 'Stopped'
      end
    end

    def trapped(sig)
      logger.info "Signal #{sig} trapped"
    end

    def stop
      # FIXME
      # @pid_file.logger = logger
      @pid_file.kill(:TERM)
    end

    def alive?
      # FIXME
      # @pid_file.logger = logger
      @pid_file.alive?
    end

    def run
      raise 'must be overriden'
    end

  end

end
