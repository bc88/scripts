#!/bin/bash
DOMAIN=$1
IPV6=`dig -t AAAA +short $DOMAIN | tail -n 1`

echo Doing $DOMAIN which has an ip of $IPV6

echo -n "Logging In..."
WGETOPTS="-q -O - --keep-session-cookies --load-cookies=.cookies.txt --save-cookies=.cookies.txt"
wget $WGETOPTS http://ipv6.he.net/certification/login.php --post-data="f_user=username&clearpass=&f_pass=hashedpassword&Login=Login"  | html2text | grep Kyle

sleep 1s
echo -n  "Doing a Tracerout... "
TRACEOUTPUT=`traceroute6  $DOMAIN 2>&1 | sed -f urlencode.sed | sed -n '1h;2,$H;${g;s/\n/%0D%0A/g;p}'`
wget $WGETOPTS http://ipv6.he.net/certification/daily_trace.php --post-data="trtext=$TRACEOUTPUT&submit=Submit"  | html2text | grep -e "Sorry" -e "Result"

echo "Doing a Dig AAAA"
DIGOUTPUT=`dig $DOMAIN AAAA | sed -f urlencode.sed | sed -n '1h;2,$H;${g;s/\n/%0D%0A/g;p}'`
wget $WGETOPTS http://ipv6.he.net/certification/dig.php --post-data="digtext=$DIGOUTPUT&submit=Submit"  | html2text | grep -e "Sorry" -e "Result"

echo "Doing a Dig PTR"
DIG2OUTPUT=`dig -x $IPV6| sed -f urlencode.sed | sed -n '1h;2,$H;${g;s/\n/%0D%0A/g;p}'`
wget $WGETOPTS http://ipv6.he.net/certification/dig2.php --post-data="digtext=$DIG2OUTPUT&submit=Submit"  | html2text | grep -e "Sorry" -e "Result"

echo "Doing a ping6"
PING6OUTPUT=`ping6 -c 4 -n $DOMAIN| sed -f urlencode.sed | sed -n '1h;2,$H;${g;s/\n/%0D%0A/g;p}'`
wget $WGETOPTS http://ipv6.he.net/certification/ping.php --post-data="pingtext=$PING6OUTPUT&submit=Submit"  | html2text | grep -e "Sorry" -e "Result"

echo "Doing a whois on the ipv6"
WHOISOUTPUT=`whois $IPV6| sed -f urlencode.sed | sed -n '1h;2,$H;${g;s/\n/%0D%0A/g;p}'`
wget $WGETOPTS http://ipv6.he.net/certification/whois.php --post-data="whoistext=$WHOISOUTPUT&submit=Submit"  | html2text | grep -e "Sorry" -e "Result"
