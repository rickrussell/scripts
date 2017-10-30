# allow iperf
iptables -A INPUT -p tcp -m tcp --sport 5001 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 5001 -j ACCEPT
iptables -A INPUT -p udp -m udp --sport 5001 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 5001 -j ACCEPT
