cat << EOF > /etc/openvpn/server111.conf

port 111
proto udp
dev tun
max-clients 100
ca /etc/openvpn/keys/ca.crt
cert /etc/openvpn/keys/server.crt
key /etc/openvpn/keys/server.key
dh /etc/openvpn/keys/dh.pem
username-as-common-name
client-cert-not-required
auth-user-pass-verify /etc/openvpn/script/login via-env
script-security 3
tmp-dir "/etc/openvpn/" # 
server 10.7.0.0 255.255.255.0
push "redirect-gateway def1" 
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 1.0.0.1"
keepalive 1 30
persist-key 
persist-tun
verb 3
status /var/www/html/status/tcp111.txt
#log-append /etc/openvpn/log/openvpn.log

EOF

