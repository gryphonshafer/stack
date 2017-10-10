#!/usr/bin/env bash

apt-get install clamav clamav-daemon

usermod -a -G clamav amavis
usermod -a -G clamav clamav
usermod -a -G amavis clamav
usermod -a -G amavis amavis

perl -e '
    open( $f, "<", $ARGV[0] );
    $f = join( "", <$f> );
    $f =~ s/^(#\@bypass_virus.*?;)/ $f = $1; $f =~ s|^#||msg; $f /msge;
    print $f;
' /etc/amavis/conf.d/15-content_filter_mode > /tmp/15-content_filter_mode
mv /tmp/15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode

freshclam --quiet
service clamav-freshclam restart
service amavis restart
