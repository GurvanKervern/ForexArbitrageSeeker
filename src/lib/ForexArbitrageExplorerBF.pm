package ForexArbitrageExplorerBF;

use strict;
use warnings;

use Data::Dumper;

my $path_queue = [];
my $wanted_profitability = 3;

sub start_search {
    my ($currency_hash_ref) = @_;
    for my $symbol (keys %$currency_hash_ref) {
        push(@$path_queue, [{'currency' => $symbol,'amount' => 1000}]);
    }
    search_paths($currency_hash_ref);
}

sub search_paths {
    my $currency_hash_ref = shift;
    while(my $trade_list_ref = shift @$path_queue) {
        check_trade_list($trade_list_ref, $currency_hash_ref);
    }
}       

sub check_trade_list {
    my ($trade_list_ref, $currency_hash_ref) = @_;
    my $profitability = get_profitability($trade_list_ref, $currency_hash_ref);
    if($profitability > $wanted_profitability) {
        printf "PROFIT : %.2f : ", $profitability;
        print_trade_list($trade_list_ref);
        my $last_currency = $trade_list_ref->[-1]->{'currency'};
        for my $new_currency (keys %{$currency_hash_ref->{$last_currency}}) {
            my $rate = $currency_hash_ref->{$last_currency}->{$new_currency};
            next if $rate == 0;
            my $new_amount = $rate * $trade_list_ref->[-1]->{'amount'};
            my @new_trade_list = @$trade_list_ref;
            push @new_trade_list, {'currency' => $new_currency, 'amount' => $new_amount};
            push @$path_queue, \@new_trade_list;
        }
    }
}

sub get_profitability {
    my ($trades_list_ref, $currency_hash_ref) = @_;
    my $list_length = scalar(@{$trades_list_ref});
    #print "List length $list_length\n";
    #print @$path_queue;
    return 5 if $list_length < 3;
    my $first_currency = $trades_list_ref->[0]->{'currency'};
    my $first_amount = $trades_list_ref->[0]->{'amount'};
    my $last_currency = $trades_list_ref->[-1]->{'currency'};
    my $last_amount = $trades_list_ref->[-1]->{'amount'};
    my $theoretical_amount = $currency_hash_ref->{$first_currency}->{$last_currency} * $first_amount;
    return -100 if $theoretical_amount == 0;
    my $profitability = (($last_amount / $theoretical_amount) - 1 ) * 100;
    return $profitability;
}

sub print_trade_list {
    my $trades_list_ref = shift;
    my @string_list = map { sprintf("%.2f %s", $_->{'amount'}, $_->{'currency'}) } (@$trades_list_ref);
    print(join(" -> ", @string_list) ."\n");
}

1;
