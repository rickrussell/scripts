# deny iperf
iptables -D INPUT -p tcp -m tcp --sport 5001 -j ACCEPT
iptables -D INPUT -p tcp -m tcp --dport 5001 -j ACCEPT
iptables -D INPUT -p udp -m udp --sport 5001 -j ACCEPT
iptables -D OUTPUT -p udp -m udp --dport 5001 -j ACCEPT
