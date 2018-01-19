# Noneck's IPtables script
# $ chmod +x set_iptables.sh
# $ sudo ./set_iptables.sh
# After importing:
# $ sudo iptables-save > iptables-current.$(date +%Y%m%d_%H%M)
# To Restore
# $ sudo iptables-restore < iptables-current.date
# reference:
# https://www.digitalocean.com/community/tutorials/iptables-essentials-common-firewall-rules-and-commands

# ALLOWED_SUBNET="10.0.0.0/16"
INTERFACE=$(ip -o link show | sed -rn '/^[0-9]+: en/{s/.: ([^:]*):.*/\1/p}')
ALLOWED_SUBNET="10.66.6.0/24"
ALL="0.0.0.0"

# loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# block all null packets
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
# block syn flood attack
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
# block XMAS or recon packets
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
# allow what we request/want
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# OpenVPN
iptables -A INPUT -i $INTERFACE -m state --state NEW -p tcp --dport 1194 -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o $INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $INTERFACE -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $INTERFACE -j MASQUERADE
iptables -A OUTPUT -o tun+ -j ACCEPT
# DNS out
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
# icmp (ping) outside to inside
iptables -A INPUT -p icmp --icmp-type echo-request -s $ALLOWED_SUBNET -j ACCEPT
# icmp (ping) inside to outside
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
# SSH
iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
# NFS Server
#iptables -A INPUT -s $ALLOWED_SUBNET -d $ALLOWED_SUBNET -p udp -m multiport --dports 10053,111,2049,32769,875,892 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A INPUT -s $ALLOWED_SUBNET -d $ALLOWED_SUBNET -p tcp -m multiport --dports 10053,111,2049,32803,875,892 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -s $ALLOWED_SUBNET -d $ALLOWED_SUBNET -p udp -m multiport --sports 10053,111,2049,32769,875,892 -m state --state ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -s $ALLOWED_SUBNET -d $ALLOWED_SUBNET -p tcp -m multiport --sports 10053,111,2049,32803,875,892 -m state --state ESTABLISHED -j ACCEPT
# IMAP & IMAPS
iptables -A INPUT -p tcp --dport 143 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 143 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 993 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 993 -m state --state ESTABLISHED -j ACCEPT
# CUPS from $ALLOWED_SUBNET
#iptables -A INPUT -p tcp --destination-port 631 -m state --state NEW -s $ALLOWED_SUBNET -j ACCEPT
#iptables -A INPUT -p udp --destination-port 631 -m state --state NEW -s $ALLOWED_SUBNET -j ACCEPT
#Printing/NetBIOS from $ALLOWED_SUBNET
#iptables -A INPUT -p udp -m udp --dport 137 -s $ALLOWED_SUBNET -j ACCEPT
#iptables -A INPUT -p udp -m udp --dport 138 -s $ALLOWED_SUBNET -j ACCEPT
#iptables -A INPUT -p tcp --dport 139 -s $ALLOWED_SUBNET -j ACCEPT
#iptables -A INPUT -p tcp --dport 445 -s $ALLOWED_SUBNET -j ACCEPT
# Local Dev Server Port: Ruby/Python/React
#iptables -A OUTPUT -p tcp --dport 3000 -s $ALLOWED_SUBNET -j ACCEPT
#iptables -A INPUT -p tcp --sport 3000 -s $ALLOWED_SUBNET -j ACCEPT
# Enable Logging
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
iptables -A LOGGING -j DROP
# Accept what we want out
iptables -P OUTPUT ACCEPT
# allow Established outgoing connections
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
# Drop invalid packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
# Drop the rest.
iptables -A FORWARD -j DROP
iptables -P INPUT DROP
