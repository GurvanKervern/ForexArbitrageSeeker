package CurrencyRatesTreeBuilders::ExchangeRateApi;

use strict;
use warnings;

use JSON;

sub populate_hash {
    my ($directory, $hash_ref) = @_;
    my @files = glob("${directory}/*json");
    for my $filename (@files) {
        replace_with_higher_values($filename, $hash_ref);
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

sub replace_with_higher_values {
    my ($filename, $hash_ref) = @_;
    my %currency_rates = %$hash_ref;
    open my $fh, '<', $filename or die("couldnt open $filename");
    read $fh, my $json_string, -s $fh;
    my $data = decode_json($json_string);
    my $base_currency = $data->{'base_code'} ;
    my $current_rates = $hash_ref->{$base_currency};
    my $new_rates = $data->{'conversion_rates'};
    print "$new_rates\n";
    my %n_r = %$new_rates;
    #for my $symbol (keys( %{$new_rates})) {
    for my $symbol (keys %n_r) {
        my $old_value = $current_rates->{$symbol};
        my $new_value = $new_rates->{$symbol};
        if(! defined $old_value) {
            $current_rates->{$symbol} = $new_value;
        } elsif($new_value > $old_value) {
            print STDERR "Replaced $base_currency $symbol from $old_value to $new_value\n";
            $current_rates->{$symbol} = $new_value;
        }
    }
}

1;
