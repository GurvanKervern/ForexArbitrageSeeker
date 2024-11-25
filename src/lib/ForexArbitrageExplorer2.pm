package ForexArbitrageExplorer2;

use strict;
use warnings;
use Data::Dumper;

my $wanted_profitability = 1;

sub string_a_perl {
    my ($trade_list_ref, $currency_hash_ref) = @_;
    #print Dumper($trade_list_ref);
    my $list_length = @$trade_list_ref;
    if($list_length > 3) {
        my $has_loop = there_is_a_loop($trade_list_ref);
        if($has_loop) {
            manage_loop($trade_list_ref, $currency_hash_ref);
            return 0;
       }
    }
    my ($profitability, $loop_profitability) = get_profitabilities($trade_list_ref, $currency_hash_ref);
    write_profit($trade_list_ref, $profitability) if ($profitability > $wanted_profitability);
    if($profitability > $wanted_profitability or $loop_profitability > $wanted_profitability or $list_length <= 3) {
        #TODO add last profitability conditions and list length here
        my $last_currency = $trade_list_ref->[-1]->{'currency'};
        for my $new_currency (keys %{$currency_hash_ref->{$last_currency}}) {
            my $rate = $currency_hash_ref->{$last_currency}->{$new_currency};
            next if $rate == 0;
            my $new_amount = $rate * $trade_list_ref->[-1]->{'amount'};
            my @new_trade_list = @$trade_list_ref;
            push @new_trade_list, {'currency' => $new_currency, 'amount' => $new_amount};
            string_a_perl(\@new_trade_list, $currency_hash_ref);
        }
    }
}

sub start_search {
    my ($currency_hash_ref) = @_;
    for my $symbol ( keys %$currency_hash_ref) {
        my $trade_list_ref = [];
        push(@$trade_list_ref, {'currency' => $symbol,'amount' => 1000});
        string_a_perl($trade_list_ref, $currency_hash_ref);
    }
}

sub manage_loop {
    my ($trade_list_ref, $currency_hash_ref) = @_;
    #if the loop is not from the start, check the profitability of the path
    if($trade_list_ref->[0]->{'currency'} ne $trade_list_ref->[-1]->{'currency'}) {
        my $profitability = get_profitability($trade_list_ref, $currency_hash_ref);
        if($profitability > $wanted_profitability) {
            write_profit($trade_list_ref, $profitability);
        }
        #then remove other currencies at the front of the loop
        while($trade_list_ref->[0]->{'currency'} ne $trade_list_ref->[-1]->{'currency'}) {
            shift(@$trade_list_ref);
        }
    }
    #see if loop is profitable
    my $loop_profitability = get_loop_profitability($trade_list_ref);
    if($loop_profitability > $wanted_profitability) {
        printf "LOOP!!!! : %.2f : ", $loop_profitability ;
        print_trade_list($trade_list_ref);
    }
}

sub there_is_a_loop {
    my $trade_list_ref = shift;
    my $last_currency = $trade_list_ref->[-1]->{'currency'};
    for(my $i = 0; $i < @$trade_list_ref - 1; $i++) {
        return 1 if $trade_list_ref->[$i]->{'currency'} eq $last_currency;
    }
    return 0;
}       

#sub check_if_there_is_a_loop {
#    my $trade_list_ref = shift;
#    my $first_currency = $trade_list_ref->[0]->{'currency'};
#    my $last_currency = $trade_list_ref->[-1]->{'currency'};
#    if($first_currency eq $last_currency) {
#        my $first_amount = $trade_list_ref->[0]->{'amount'};
#        my $last_amount = $trade_list_ref->[-1]->{'amount'};
#        my $profitability = ( ( $last_amount / $first_amount ) - 1 ) * 100;
#        if($profitability > $wanted_profitability) {
#            print "LOOP!!!! : $profitability ";
#            print_trade_list($trade_list_ref);
#        }
#        return 1;
#    } else {
#        return 0;
#    }
#}

sub print_trade_list {
    my $trades_list_ref = shift;
    my @string_list = map { sprintf("%.2f %s", $_->{'amount'}, $_->{'currency'}) } (@$trades_list_ref);
    print(join(" -> ", @string_list) ."\n");
}

sub get_profitabilities {
    my ($trade_list_ref, $currency_hash_ref) = @_;
    my $profitability = get_profitability($trade_list_ref, $currency_hash_ref);
    my $last_currency = $trade_list_ref->[-1]->{'currency'};
    my $new_currency = $trade_list_ref->[0]->{'currency'};
    my $rate = $currency_hash_ref->{$last_currency}->{$new_currency};
    my $new_amount = $rate * $trade_list_ref->[-1]->{'amount'};
    my @new_trade_list = @$trade_list_ref;
    push @new_trade_list, {'currency' => $new_currency, 'amount' => $new_amount};
    my $loop_profitability = get_loop_profitability(\@new_trade_list);
    return ($profitability, $loop_profitability);
}

sub get_profitability {
    my ($trades_list_ref, $currency_hash_ref) = @_;
    my $list_length = scalar(@{$trades_list_ref});
    my $first_currency = $trades_list_ref->[0]->{'currency'};
    my $first_amount = $trades_list_ref->[0]->{'amount'};
    my $last_currency = $trades_list_ref->[-1]->{'currency'};
    my $last_amount = $trades_list_ref->[-1]->{'amount'};
    my $theoretical_amount = $currency_hash_ref->{$first_currency}->{$last_currency} * $first_amount;
    return -100 if $theoretical_amount == 0;
    my $profitability = (($last_amount / $theoretical_amount) - 1 ) * 100;
    return $profitability;
}

sub get_loop_profitability {
        my $trade_list_ref = shift;
        my $first_amount = $trade_list_ref->[0]->{'amount'};
        my $last_amount = $trade_list_ref->[-1]->{'amount'};
        my $profitability = ( ( $last_amount / $first_amount ) - 1 ) * 100;
        return $profitability;
}

sub write_profit {
    my ($trade_list_ref, $profitability) = @_;
    printf "PROFIT : %.2f : ", $profitability ;
    print_trade_list($trade_list_ref);
}

1;
