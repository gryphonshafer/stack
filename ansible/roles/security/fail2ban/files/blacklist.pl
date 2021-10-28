#!/usr/bin/env perl
use strict;
use warnings;

my $conf = {
    whitelist     => '/etc/shorewall/whitelist',
    blacklist_dir => '/etc/shorewall/rules.d/blacklists',
    fail2ban      => [
        {
            name      => 'ssh-fails',
            threshold => 6,
            command   => q{zgrep -E '\[ssh\]' /var/log/fail2ban.log /var/log/fail2ban.log.1},
        },
    ],
    restart => [ qw( shorewall fail2ban ) ],
};

my $time = scalar(localtime);

my @whitelist;
if ( open( my $whitelist, '<', $conf->{whitelist} ) ) {
    @whitelist = map { s/#.*$//; s/\s+//; $_ } <$whitelist>;
}

push( @{ $conf->{actions} }, sub {
    for my $fail2ban ( @{ $conf->{fail2ban} } ) {
        my %ips;
        $ips{$_}++ for (
            grep { defined } map { /\b(\d+\.\d+\.\d+\.\d+)\b/; $1 } `$fail2ban->{command}`
        );

        my $blacklist = $conf->{blacklist_dir} . '/' . $fail2ban->{name};
        my @blacklist;
        if ( open( my $blacklist, '<', $blacklist ) ) {
            @blacklist = grep { defined } map { /\b(\d+\.\d+\.\d+\.\d+)\b/; $1 } <$blacklist>;
        }

        open( my $blacklist_w, '>>', $blacklist ) or die $!;
        printf $blacklist_w "DROP net:%-15s all # %4d on %s\n", $_, $ips{$_}, $time for (
            sort grep {
                my $this_ip = $_;
                $ips{$this_ip} >= $fail2ban->{threshold}
                    and not grep { $this_ip eq $_ } @whitelist
                    and not grep { $this_ip eq $_ } @blacklist;
            } keys %ips
        );
    }
} );

END {
    $_->() for ( @{ $conf->{actions} || [] } );
    system("service $_ restart") for ( @{ $conf->{restart} || [] } );
}
