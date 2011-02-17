#!/bin/bash
cd /root/he.net
DOMAIN=`head ipv6sites -n 1`

./login.sh $DOMAIN

#delete first line
sed -i '1d' ipv6sites
