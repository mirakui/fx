RECORD_CURRENCIES = ["USD/JPY", "EUR/JPY", "GBP/JPY"]

require 'market/sbi_market'
require 'recorder/file_recorder'
MARKET_CLASS          = SbiMarket
MARKET_RECORDER_CLASS = FileRecorder

require 'trader/stub_trader'
require 'strategy/stub_strategy'
TRADER_CLASS          = StubTrader
STRATEGY_CLASS        = StubStrategy

MARKET_FREQUENCY_SECOND = 10

