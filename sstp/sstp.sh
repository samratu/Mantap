#!/bin/bash
# My Telegram : https://t.me/zerossl
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Getting
MYIP=$(wget -qO- ipinfo.io/ip);

# Link Hosting Kalian
wisnuvpn="raw.githubusercontent.com/samratu/large/file/sstp"

MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NIC=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
OS=$ID
ver=$VERSION_ID
if [[ $OS == 'ubuntu' ]]; then
if [[ "$ver" = "18.04" ]]; then
yoi=Ubuntu18
elif [[ "$ver" = "20.04" ]]; then
yoi=Ubuntu20
fi
elif [[ $OS == 'debian' ]]; then
if [[ "$ver" = "9" ]]; then
yoi=Debian9
elif [[ "$ver" = "10" ]]; then
yoi=Debian10
fi
fi
mkdir /home/sstp
touch /home/sstp/sstp_account
touch /var/lib/wisnucs/data-user-sstp
#detail nama perusahaan
country=ID
state=Jawa-Tengah
locality=Sukoharjo
organization=gandringVPN
organizationalunit=gandring
commonname=gandring
email=djarumpentol01@gmail.com
#export KEY_COUNTRY="US"
#export KEY_PROVINCE="California"
#export KEY_CITY="San-Fransisco"
#export KEY_ORG="Cloudflare Inc."
#export KEY_EMAIL="djarumpentol01@gmail.com"
#export KEY_OU="www.cloidflare.com"

#install sstp
apt-get install -y build-essential cmake gcc linux-headers-`uname -r` git libpcre3-dev libssl-dev liblua5.1-0-dev ppp
git clone https://github.com/accel-ppp/accel-ppp.git /opt/accel-ppp-code
mkdir /opt/accel-ppp-code/build
cd /opt/accel-ppp-code/build/
cmake -DBUILD_IPOE_DRIVER=TRUE -DBUILD_VLAN_MON_DRIVER=TRUE -DCMAKE_INSTALL_PREFIX=/usr -DKDIR=/usr/src/linux-headers-`uname -r` -DLUA=TRUE -DCPACK_TYPE=$yoi ..
make
cpack -G DEB
dpkg -i accel-ppp.deb
mv /etc/accel-ppp.conf.dist /etc/accel-ppp.conf
wget -O /etc/accel-ppp.conf "https://${wisnuvpn}/accel.conf"
sed -i $MYIP2 /etc/accel-ppp.conf
chmod +x /etc/accel-ppp.conf
systemctl start accel-ppp
systemctl enable accel-ppp
#gen cert sstp
cd /home/sstp
openssl genrsa -out ca.key 4096 > /dev/null 2>&1
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt \
-subj "/C=ID/ST=Jawa-Tengah/L=Sukoharjo/O=GANDRING-VPN/OU=GANDRING/CN=GANDRING-VPN/emailAddress=djarumpentol01@gmail.com" > /dev/null 2>&1
#-subj "/C=US/ST=California/L=San-Fransisco/O=Cloudflare Inc./OU=www.cloudflare.com/CN=Managed CA f04e6b9f08b2fe102b1106b9aa860b8e/emailAddress=djarumpentol01@gmail.com"
openssl genrsa -out server.key 4096 > /dev/null 2>&1
openssl req -new -key server.key -out ca.csr \
-subj "/C=ID/ST=Jawa-Tengah/L=Sukoharjo/O=GANDRING-VPN/OU=GANDRING/CN=GANDRING-VPN/emailAddress=djarumpentol01@gmail.com"  > /dev/null 2>&1
#-subj "/C=US/ST=California/L=San-Fransisco/O=Cloudflare Inc./OU=www.cloudflare.com/CN=Managed CA f04e6b9f08b2fe102b1106b9aa860b8e/emailAddress=djarumpentol01@gmail.com"
openssl x509 -req -days 3650 -in ca.csr -CA ca.crt -CA key ca.key -set_serial 01 -out server.crt
#cp /etc/ssl/private/fullchain.pem /home/vps/public_html/server.pem
cp /home/sstp/server.crt /home/vps/public_html/server.crt
sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 666 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m udp -p udp --dport 666 -j ACCEPT
sudo iptables-save > /etc/iptables.up.rules
sudo iptables-restore -t < /etc/iptables.up.rules
sudo netfilter-persistent save > /dev/null
sudo netfilter-persistent reload > /dev/null
#input perintah sstp
wget -O /usr/bin/addsstp https://${wisnuvpn}/addsstp.sh && chmod +x /usr/bin/addsstp
wget -O /usr/bin/delsstp https://${wisnuvpn}/delsstp.sh && chmod +x /usr/bin/delsstp
wget -O /usr/bin/ceksstp https://${wisnuvpn}/ceksstp.sh && chmod +x /usr/bin/ceksstp
wget -O /usr/bin/renewsstp https://${wisnuvpn}/renewsstp.sh && chmod +x /usr/bin/renewsstp
wget -O /usr/bin/trial-sstp https://${wisnuvpn}/yrial-sstp.sh && chmod +x /usr/bin/trial-sstp

sleep 1
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "
SSTP successfully installed..
"
sleep 2
clear
rm -f /root/sstp.sh
