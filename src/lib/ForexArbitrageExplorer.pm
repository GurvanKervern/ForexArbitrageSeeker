package ForexArbitrageExplorer;

use strict;
use warnings;

use List::Util qw(first);
use Data::Dumper;

my $debug = 0;
my $trade_nb = 0;

sub string_a_perl {
    my ($trades_list_ref, $currency_hash_ref, $new_currency) = @_;
    my $last_currency = $trades_list_ref->[-1]->{'currency'};
    my $last_amount = $trades_list_ref->[-1]->{'amount'};
    my $rate = $currency_hash_ref->{$last_currency}->{$new_currency};
    if($rate == 0) {
        return 0;
    }
    my $new_amount = $last_amount * $rate;

    my $loop_present = check_if_loop_present($trades_list_ref, $new_currency);

    #put new trade at the end
    push(@$trades_list_ref, {'currency' => $new_currency, 'amount' => $new_amount});
    
    #sleep(1);
    if( $loop_present ) {
        my $profitable = check_if_trades_are_profitable($trades_list_ref, $currency_hash_ref);
        evaluate_loop_profitability($trades_list_ref, $currency_hash_ref);
        #$trade_nb++;
        return 0;
    } else {
        #recursion
        foreach my $tradeable_currency (keys(%{$currency_hash_ref->{$new_currency}})) {
            my @list_copy = @$trades_list_ref;
            my $list_ref = \@list_copy;
            string_a_perl(\@list_copy, $currency_hash_ref, $tradeable_currency);
        }
    }
}

sub check_if_loop_present {
    my ($trades_list_ref, $new_currency) = @_;
    foreach my $trade (@$trades_list_ref) {
        if( $trade->{'currency'} eq $new_currency ) {
            return 1;
        }
    }
    return 0;
}

sub check_if_trades_are_profitable {
    my ($trades_list_ref, $currency_hash_ref) = @_;
    my $first_currency = $trades_list_ref->[0]->{'currency'};
    my $first_amount = $trades_list_ref->[0]->{'amount'};
    my $last_currency = $trades_list_ref->[-1]->{'currency'};
    my $last_amount = $trades_list_ref->[-1]->{'amount'};
    my $theoretical_amount = $currency_hash_ref->{$first_currency}->{$last_currency} * $first_amount;
    if($last_amount > $theoretical_amount / 100 * 101) {
        printf "PROFIT!!! Should have been %.2f, but it is %.2f %s\n", $theoretical_amount, $last_amount, $last_currency ;
        print_trade_list($trades_list_ref) ;
        return 1;
    } else {
        return 0;
    }
}

sub print_trade_list {
    my $trades_list_ref = shift;
    my @string_list = map { sprintf("%.2f %s", $_->{'amount'}, $_->{'currency'}) } (@$trades_list_ref);
    print(join(" -> ", @string_list) ."\n");
}

sub evaluate_loop_profitability {
    my ($trades_list_ref, $currency_hash_ref) = @_;
    my $last_currency = $trades_list_ref->[-1]->{'currency'};
    while($trades_list_ref->[0]->{'currency'} ne $last_currency) {
        #print_trade_list($trades_list_ref);
        shift @$trades_list_ref;
    }
    check_if_trades_are_profitable($trades_list_ref, $currency_hash_ref);
}

1;
