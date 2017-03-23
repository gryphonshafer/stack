FROM debian:latest

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install curl perl-modules build-essential libssl-dev git vim

ENV PERLBREW_ROOT="/opt/perl5"

RUN curl -skL http://install.perlbrew.pl | bash && \
    echo ". $PERLBREW_ROOT/etc/bashrc" >> /etc/bash.bashrc && \
    bash -c '. $PERLBREW_ROOT/etc/bashrc && \
        perlbrew install-cpanm && \
        perlbrew install --notest --switch stable && \
        perlbrew switch `perlbrew list` && \
        perlbrew lib create local && \
        perlbrew switch @local'

COPY cpanfile /

RUN bash -c '. $PERLBREW_ROOT/etc/bashrc && \
    cpanm -n -f --with-develop --with-all-features --installdeps .'
