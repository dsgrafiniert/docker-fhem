#! /bin/sh

if [[ ! -f /opt/fhem/COPIED ]]; then
  cp -R /opt/fhem-5.8/* /opt/fhem
  touch /opt/fhem/COPIED
fi

exec /usr/bin/perl fhem.pl fhem.cfg
