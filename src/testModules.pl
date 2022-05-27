use strict;
use warnings;

use lib './lib/';

use CurrencyRatesTreeBuilders::OpenExchangeRatesOrg qw/populate_hash/; 
use CurrencyRatesTreeBuilders::ExchangeRateHost qw/populate_hash/; 
use CurrencyRatesTreeBuilders::ExchangeRateApi qw/populate_hash/; 

use ForexArbitrageExplorer;

my $currency_hash = {};
CurrencyRatesTreeBuilders::ExchangeRateHost::populate_hash($ARGV[0], $currency_hash);
CurrencyRatesTreeBuilders::ExchangeRateApi::populate_hash($ARGV[1], $currency_hash);

my $trades_list_reference = [];
push(@$trades_list_reference, {'currency' => 'SGD', 'amount' => 1000});
ForexArbitrageExplorer::string_a_perl($trades_list_reference, $currency_hash, 'EUR');
