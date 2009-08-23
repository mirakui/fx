require 'environment'
require 'loggable'
require 'pid_file'
require 'daemon'

class FxDaemon < Gena::Daemon

  DAEMON_NAME   = 'fxd'
  PID_FILE_PATH = File.join(::LOG_DIR, "#{DAEMON_NAME}.pid")

  def initialize
    super(DAEMON_NAME, PID_FILE_PATH)
    @killed = false
  end

  def run
    @market          = ::MARKET_CLASS.new
    @market_recorder = ::MARKET_RECORDER_CLASS.new @market
    @trader          = ::TRADER_CLASS.new
    @strategy        = ::STRATEGY_CLASS.new @trader

    loop do
      reload
      record
      calc
      break if main_break_condition
      sleep ::MARKET_FREQUENCY_SECOND
    end
    logger.debug "Finished run"
  end

  def trapped(sig)
    logger.info "Signal #{sig} trapped"
    @killed = true
  end

  private
  def reload
    @market.reload_prices
  end

  def record
    @market_recorder.record
  end

  def calc
    @strategy.calc(@market.prices)
  end

  def main_break_condition
    @killed
  end

  def start__
    # http://snippets.dzone.com/posts/show/2265
    fork do
      Process.setsid
      exit if fork
      STDIN.reopen "/dev/null"
      STDOUT.reopen "/dev/null", "a"
      STDERR.reopen STDOUT

      @market          = ::MARKET_CLASS.new
      @market_recorder = ::MARKET_RECORDER_CLASS.new @market
      @trader          = ::TRADER_CLASS.new
      @strategy        = ::STRATEGY_CLASS.new @trader
      @market.logger = @market_recorder.logger = @trader.logger = @strategy.logger = @pid_file.logger = logger
      $PROGRAM_NAME = DAEMON_NAME

      logger.info "Daemon Started ##{$$}"
      @pid_file.write
      Signal.trap(:TERM) do
        logger.info 'Signal TERM trapped'
        @killed = true
      end

      main

      @pid_file.delete
      logger.info 'Stopped'
    end
  end

  def stop_
    pid = @pid_file.read
    Process.kill :TERM, pid
    logger.info "Sent :TERM to ##{pid}"
  end

  def start_
    if $DEBUG
      logger.info "Debug Started ##{$$}"
    else
      Process.daemon
      logger.info "Daemon Started ##{$$}"
    end
    @market.logger = @market_recorder.logger = @trader.logger = @strategy.logger = logger
    $PROGRAM_NAME = DAEMON_NAME
    @pid_file     = Gena::PidFile.new(PID_FILE_PATH)
    @pid_file.logger = logger
    @pid_file.write
    Signal.trap(:TERM) do
      logger.info 'Signal TERM trapped'
      @killed = true
    end

    main

    @pid_file.delete
    logger.info 'Stopped'
  end

end

