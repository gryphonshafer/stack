FROM debian:latest

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install curl perl-modules build-essential libssl-dev

RUN export PERLBREW_ROOT=/opt/perl5 && \
    curl -skL http://install.perlbrew.pl | bash && \
    bash -c '. /opt/perl5/etc/bashrc && perlbrew install-cpanm'

RUN bash -c '. /opt/perl5/etc/bashrc && \
    perlbrew install --notest --switch stable && \
    perlbrew switch `perlbrew list` && \
    perlbrew lib create local && \
    perlbrew switch @local'

COPY cpanfile /

RUN bash -c '. /opt/perl5/etc/bashrc && \
    cpanm -n -f --with-develop --with-all-features --installdeps .'
