#!/usr/bin/env sh

if [ -d /opt/perl5 ]
then
    USER="www-data"
    HOME="/var/www"
    LOGNAME="www-data"
    MAIL="/var/mail/www-data"

    PERLBREW_ROOT="/opt/perl5"
    PERLBREW_HOME="${HOME}/.perlbrew"
    . ${PERLBREW_HOME}/init

    __perlbrew_code="$(${PERLBREW_ROOT}/bin/perlbrew env ${PERLBREW_PERL}@${PERLBREW_LIB})"
    eval "$__perlbrew_code"

    echo 'export USER="'$USER'"'
    echo 'export HOME="'$HOME'"'
    echo 'export LOGNAME="'$LOGNAME'"'
    echo 'export MAIL="'$MAIL'"'
    echo 'export PERL5LIB="'$PERL5LIB'"'
    echo 'export PERLBREW_HOME="'$PERLBREW_HOME'"'
    echo 'export PERLBREW_LIB="'$PERLBREW_LIB'"'
    echo 'export PERLBREW_MANPATH="'$PERLBREW_MANPATH'"'
    echo 'export PERLBREW_PATH="'$PERLBREW_PATH'"'
    echo 'export PERLBREW_PERL="'$PERLBREW_PERL'"'
    echo 'export PERLBREW_ROOT="'$PERLBREW_ROOT'"'
    echo 'export PERLBREW_SHELLRC_VERSION="'$PERLBREW_SHELLRC_VERSION'"'
    echo 'export PERLBREW_VERSION="'$PERLBREW_VERSION'"'
    echo 'export PERL_LOCAL_LIB_ROOT="'$PERL_LOCAL_LIB_ROOT'"'
    echo 'export PERL_MB_OPT="'$PERL_MB_OPT'"'
    echo 'export PERL_MM_OPT="'$PERL_MM_OPT'"'
    echo 'export PATH="'$PERLBREW_PATH':'$PATH'"'
    echo 'export MANPATH="'$PERLBREW_MANPATH':'$MANPATH'"'
fi

exit 0
