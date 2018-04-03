#!/bin/bash
# Needs to be run as root.
# This script removes all iptables rules
# If you use docker, restart the docker process to
# re-create your docker rules.
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT