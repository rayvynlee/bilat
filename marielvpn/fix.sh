#!/bin/bash
#MarielVPN GCloudFIX


rm -rf /etc/openvpn/server.conf
rm -rf /etc/openvpn/server443.conf

wget -O /etc/openvpn/server.conf https://raw.githubusercontent.com/rayvynlee/bilat/master/marielvpn/server.conf
wget -O /etc/openvpn/server443.conf https://raw.githubusercontent.com/rayvynlee/bilat/master/marielvpn/server443.conf

chmod -R 755 /etc/openvpn/*
echo "sysctl -p" >> /etc/rc.local
rm -rf *.sh
reboot
