# Noneck's IPtables script
# $ chmod +x set_iptables.sh
# $ sudo ./set_iptables.sh
# After importing:
# $ sudo iptables-save > iptables-current.$(date +%Y%m%d_%H%M)
# To Restore
# $ sudo iptables-restore < iptables-current.date
# reference:
# https://www.digitalocean.com/community/tutorials/iptables-essentials-common-firewall-rules-and-commands

WORK_SUBNET="10.0.0.0/16"

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
# DNS out
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
# icmp (ping) outside to inside
iptables -A INPUT -p icmp --icmp-type echo-request -s $WORK_SUBNET -j ACCEPT
# icmp (ping) inside to outside
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
# SSH
iptables -A INPUT -p tcp -s $WORK_SUBNET --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
# IMAP & IMAPS
iptables -A INPUT -p tcp --dport 143 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 143 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 993 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 993 -m state --state ESTABLISHED -j ACCEPT
# CUPS from $WORK_SUBNET
iptables -A INPUT -p tcp  --destination-port 631  -m state --state NEW -s $WORK_SUBNET -j ACCEPT
iptables -A INPUT -p udp  --destination-port 631  -m state --state NEW -s $WORK_SUBNET -j ACCEPT
#Printing/NetBIOS from $WORK_SUBNET
iptables -A INPUT -p udp -m udp --dport 137 -s $WORK_SUBNET -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 138 -s $WORK_SUBNET -j ACCEPT
iptables -A INPUT -p tcp --dport 139 -s $WORK_SUBNET -j ACCEPT
iptables -A INPUT -p tcp --dport 445 -s $WORK_SUBNET -j ACCEPT
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