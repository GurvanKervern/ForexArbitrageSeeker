package CurrencyRatesTreeBuilders::OpenExchangeRatesOrg;

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
    open my $fh, '<', $filename or die("couldnt open $filename");
    my $json_string = <$fh> ;
    print($json_string);
    my $data = decode_json($json_string);
    print Dumper($data);
}

1;
