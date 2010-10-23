#!/bin/bash
#
# Adds a self signed cert into the chrome db
# Courtesy of Sean:
# http://www.tummy.com/journals/entries/jafo_20101019_155619

if [ $# -ne 1 ]; then
	echo Usage: add-cert-to-chrome.sh DOMAINNAME
	exit 1
fi
if ! which certutil ; then
	echo You dont have the certutil program
	exit 1
fi

SERVERNAME=$1
#  Get the SSL certificate
openssl s_client -showcerts -connect $SERVERNAME:443 >/tmp/$SERVERNAME.cert </dev/null

#  Install it, use P,, after the bug mentioned above is fixed
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n $SERVERNAME -i /tmp/$SERVERNAME.cert

#  List the certificate.
certutil -d sql:$HOME/.pki/nssdb -L
