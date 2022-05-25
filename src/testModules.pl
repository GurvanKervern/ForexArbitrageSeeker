use strict;
use warnings;

use lib './lib/';

use CurrencyRatesTreeBuilders::OpenExchangeRatesOrg qw/populate_hash/; 
use CurrencyRatesTreeBuilders::ExchangeRateHost qw/populate_hash/; 

CurrencyRatesTreeBuilders::ExchangeRateHost::populate_hash($1, {});
