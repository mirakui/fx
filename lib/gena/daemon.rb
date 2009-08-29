require 'gena/pid_file'

module Gena

  class Daemon

    include Loggable

    attr_accessor :pid_file, :console_mode

    def initialize(daemon_name, pid_file_path)
      @daemon_name = daemon_name
      @pid_file = PidFile.new(pid_file_path)
      @console_mode = false
    end

    # http://snippets.dzone.com/posts/show/2265
    def start
      if @console_mode
        start_console
      else
        start_daemon
      end
    end

    def trapped(sig)
      logger.info "Signal #{sig} trapped"
    end

    def stop
      @pid_file.kill(:TERM)
    end

    def alive?
      @pid_file.alive?
    end

    def run
      raise 'must be overriden'
    end

    private
    def start_console
      $PROGRAM_NAME = @daemon_name

      logger.info "Daemon #{@daemon_name} Started ##{$$}"
      @pid_file.write
      Signal.trap(:TERM) do
        trapped(:TERM)
      end

      run

      @pid_file.delete
      logger.info 'Stopped'
    rescue StandardError => e
      logger.error [e.to_s, e.backtrace].flatten.join("\n\t")
    rescue Object => e
      logger.error "Unexpected Exception: #{e.inspect}"
    end

    def start_daemon
      fork do
        Process.setsid
        exit if fork
        STDIN.reopen "/dev/null"
        STDOUT.reopen "/dev/null", "a"
        STDERR.reopen STDOUT

        start_console
      end
    end

  end

end
