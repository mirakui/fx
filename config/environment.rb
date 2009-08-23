BASE_DIR   = File.join(File.dirname(__FILE__), '..')
LIB_DIR    = File.join(BASE_DIR, 'lib')
LOG_DIR    = File.join(BASE_DIR, 'log')
CONFIG_DIR = File.join(BASE_DIR, 'config')
PRICE_DIR  = File.join(LOG_DIR,  'price')
$: << LIB_DIR

