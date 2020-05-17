#!/usr/bin/env bash

zgrep -E '\[sasl\] Ban ' /var/log/fail2ban.log* | \
    perl -ne '/(\d+\.\d+\.\d+\.\d+)/; print "$1\n"' | sort | uniq -c | sort -nr \
    > /tmp/fail2ban_repeaters

cat /tmp/fail2ban_repeaters | \
    perl -ne '/(\d+)\s+(\d+\.\d+\.\d+\.\d+)/; print ( ( $1 >= 0 ) ? "$2\n" : "null\n" )' | \
    grep -v null | sort | \
    perl -ne 'chomp; print "DROP net:$_ all\n"' \
    > /tmp/shorewall_blacklist_auto

cat /etc/shorewall/rules.d/blacklist_auto /tmp/shorewall_blacklist_auto | sort | uniq \
    > /tmp/shorewall_blacklist_auto_sort_uniq

cat /tmp/shorewall_blacklist_auto_sort_uniq > /etc/shorewall/rules.d/blacklist_auto

rm \
    /tmp/fail2ban_repeaters \
    /tmp/blacklist_auto_new \
    /tmp/shorewall_blacklist_auto \
    /tmp/shorewall_blacklist_auto_sort_uniq

/usr/sbin/service shorewall reload
