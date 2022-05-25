package CurrencyRatesTreeBuilders::ExchangeRateHost;

use strict;
use warnings;

use JSON;

sub populate_hash {
    my ($directory, $hash_ref) = @_;
    my @files = glob("${directory}/*json");
    for my $filename (@files) {
        process_file($filename, $hash_ref);
    }
}

sub process_file {
    my ($filename, $hash_ref) = @_;
    my %currency_rates = %$hash_ref;
    open my $fh, '<', $filename or die("couldnt open $filename");
    my $json_string = <$fh> ;
    my $data = decode_json($json_string);
    my $base_currency = $data->{'base'} ;
    $hash_ref->{$base_currency} = $data->{'rates'};
}

1;
