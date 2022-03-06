#!/usr/bin/env python
from socket import socket
import secrets import dorho_voucher

# -----------------------------------------------------------------------------
voucher=dorho_voucher
# -----------------------------------------------------------------------------

print('initiating "DorHo WiFi bamboozler 9000" protocol...\n')

s= socket()
s.connect( ('172.16.0.1', 8002) )

# defining the request
req = 'POST /index.php?zone=dorho HTTP/1.0'
req += '\r\n' + 'User-Agent: w3m/0.5.3'
req += '\r\n' + 'Accept: text/html, text/*;q=0.5, image/*'
req += '\r\n' + 'Accept-Encoding: gzip, compress, bzip, bzip2, deflate'
req += '\r\n' + 'Accept-Language: en;q=1.0'
req += '\r\n' + 'Host: 172.16.0.1:8002'
req += '\r\n' + 'Referer: http://172.16.0.1:8002/index.php?zone=dorho&redirurl=http%3A%2F%2F1.1.1.1%2Findex.html'
req += '\r\n' + 'Content-Type: application/x-www-form-urlencoded'
req += '\r\n' + 'Content-Length: 105'
req += '\r\n' + ''
req += '\r\n' + 'auth_user=&auth_pass=&auth_voucher=' + voucher + '&redirurl=http%3A%2F%2F1.1.1.1%2Findex.html&accept=Continue'
req += '\r\n' + ''

#print('request:')
#print(req)
#print('sending login information...')
s.sendall(bytes(req, 'ASCII'))

#print("received data:")
reply = str(s.recv(4096))
#print(reply)
s.close()
