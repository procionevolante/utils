#!/bin/sh
# simple script that shows how a stupid wifi login can be fooled easily.
# This scripts also shows that I'm really lazy at tipying passwords very often
source ~/bin/secrets
voucher="${dorho_voucher}"

echo 'initiating "DOrHO WiFi bamboozler 9000" protocol...'

unix2dos << EOF | nc 172.16.0.1 8002 > /dev/null
POST /index.php?zone=dorho HTTP/1.0
User-Agent: w3m/0.5.3+git20190105
Accept: text/html, text/*;q=0.5, image/*
Accept-Encoding: gzip, compress, bzip, bzip2, deflate
Accept-Language: en;q=1.0
Host: 172.16.0.1:8002
Referer: http://172.16.0.1:8002/index.php?zone=dorho&redirurl=http%3A%2F%2F1.1.1.1%2Findex.html
Content-Type: application/x-www-form-urlencoded
Content-Length: 105

auth_user=&auth_pass=&auth_voucher=${voucher}&redirurl=http%3A%2F%2F1.1.1.1%2Findex.html&accept=Continue

EOF

if [ $? -eq 0 ]; then
	echo done
else
	echo some error happened. Arrangiati
fi

exit
# -----------------------------------------------------------------------------
# this code is kept for historical reasons since apparently the login works
# also if we don't fake a connection to a real website before sending the
# voucher

unix2dos << 'EOF' | nc 1.1.1.1 80 > /dev/null
GET /index.html HTTP/1.0
User-Agent: w3m/0.5.3+git20190105
Accept: text/html, text/*;q=0.5, image/*
Accept-Encoding: gzip, compress, bzip, bzip2, deflate
Accept-Language: en;q=1.0
Host: 1.1.1.1

EOF

unix2dos << 'EOF' | nc 172.16.0.1 8002 > /dev/null
GET /index.php?zone=dorho&redirurl=http%3A%2F%2F1.1.1.1%2Findex.html HTTP/1.0
User-Agent: w3m/0.5.3+git20190105
Accept: text/html, text/*;q=0.5, image/*
Accept-Encoding: gzip, compress, bzip, bzip2, deflate
Accept-Language: en;q=1.0
Host: 172.16.0.1:8002
Referer: http://1.1.1.1/index.html

EOF

sleep 3

unix2dos << EOF | nc 172.16.0.1 8002 > /dev/null
POST /index.php?zone=dorho HTTP/1.0
User-Agent: w3m/0.5.3+git20190105
Accept: text/html, text/*;q=0.5, image/*
Accept-Encoding: gzip, compress, bzip, bzip2, deflate
Accept-Language: en;q=1.0
Host: 172.16.0.1:8002
Referer: http://172.16.0.1:8002/index.php?zone=dorho&redirurl=http%3A%2F%2F1.1.1.1%2Findex.html
Content-Type: application/x-www-form-urlencoded
Content-Length: 105

auth_user=&auth_pass=&auth_voucher=${voucher}&redirurl=http%3A%2F%2F1.1.1.1%2Findex.html&accept=Continue

EOF
