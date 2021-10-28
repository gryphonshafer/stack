#!/usr/bin/env perl
use strict;
use warnings;

my $blocks;
$blocks->{$_}++ for (
    map { /SRC=(\d+\.\d+\.\d+\.\d+)\b/; $1 }
        `zgrep 'Shorewall:net-fw:DROP' /var/log/messages*`
);

opendir( my $blacklists, '/etc/shorewall/rules.d/blacklists' );
for my $blacklist ( grep { not /^\./ } readdir($blacklists) ) {
    open( my $list_in, '<', '/etc/shorewall/rules.d/blacklists/' . $blacklist );

    my $data = join( '', grep { defined } map {
        /\b(\d+\.\d+\.\d+\.\d+)\b/;
        ( $blocks->{$1} and $blocks->{$1} >= 3 ) ? $_ : undef;
    } <$list_in> );

    close($list_in);

    open( my $list_out, '>', '/etc/shorewall/rules.d/blacklists/' . $blacklist );
    print $list_out $data;
}
