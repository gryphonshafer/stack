#!/usr/bin/env bash

cd /tmp
git clone https://github.com/joyent/node.git nodejs
cd /tmp/nodejs

git checkout tags/$(
    git tag -l | grep '^v' | grep -v '-' | perl -ne '
        chomp;
        push(
            @f,
            [
                $_,
                [ grep { length > 0 } split(/\D/) ]
            ]
        );
        END {
            @f =
                map { $_->[0] }
                sort {
                    $a->[1][0] <=> $b->[1][0] ||
                    $a->[1][1] <=> $b->[1][1] ||
                    $a->[1][2] <=> $b->[1][2] }
                @f;
            print $f[-1];
        }'
)

./configure --openssl-libpath=/usr/lib/ssl
make
make install

cd
rm -rf /tmp/nodejs
