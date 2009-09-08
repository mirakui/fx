BASE_DIR     = File.join(File.dirname(__FILE__), '..')
APP_DIR      = File.join(BASE_DIR, 'app')
LIB_DIR      = File.join(BASE_DIR, 'lib')
LOG_DIR      = File.join(BASE_DIR, 'log')
CONFIG_DIR   = File.join(BASE_DIR, 'config')
PRICE_DIR    = File.join(LOG_DIR,  'price')
RECIPE_DIR   = File.join(BASE_DIR, 'recipe')
STRATEGY_DIR = File.join(APP_DIR,  'strategy')
MARKET_DIR   = File.join(APP_DIR,  'market')
RECORDER_DIR = File.join(APP_DIR,  'recorder')
TRADER_DIR   = File.join(APP_DIR,  'trader')
$: << LIB_DIR
$: << APP_DIR

