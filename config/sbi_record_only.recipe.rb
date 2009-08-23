RECORD_CURRENCIES = ["USD/JPY", "EUR/JPY", "GBP/JPY"]

require 'sbi'
require 'sbi_recorder'
MARKET_CLASS          = Sbi
MARKET_RECORDER_CLASS = SbiRecorder

require 'stub_trader'
require 'stub_strategy'
TRADER_CLASS          = StubTrader
STRATEGY_CLASS        = StubStrategy

MARKET_FREQUENCY_SECOND = 10

