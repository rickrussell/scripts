#!/usr/bin/env python
""" Python utility for parsing current AWS Public IP Address Ranges into different formats. """
""" ex. get_aws_ip_ranges.py -h  """

import argparse
from urllib import *
from netaddr import *
import json
import sys

url = 'https://ip-ranges.amazonaws.com/ip-ranges.json'
response = urlopen(url)
dictionary = json.load(response)

def plain_ec2_range_list(ranges):
    subnet_ranges = list()
    for prefix in ranges['prefixes']:
        if prefix['service'] == "EC2":
            subnet_ranges.append(prefix['ip_prefix'])

    return subnet_ranges

def plain_rt53_range_list(ranges):
    subnet_ranges = list()
    for prefix in ranges['prefixes']:
        if prefix['service'] == "ROUTE53":
            subnet_ranges.append(prefix['ip_prefix'])

    return subnet_ranges

def plain_aws_range_list(ranges):
    subnet_ranges = list()
    for prefix in ranges['prefixes']:
        if prefix['service'] == "AMAZON":
            subnet_ranges.append(prefix['ip_prefix'])

    return subnet_ranges

def iptables_ec2_range_list(ranges):
    subnet_ranges = list()
    for prefix in ranges['prefixes']:
        if prefix['service'] == "EC2":
            subnet_ranges.append(prefix['ip_prefix'])

    return subnet_ranges

def iptables_rt53_range_list(ranges):
    subnet_ranges = list()
    for prefix in ranges['prefixes']:
        if prefix['service'] == "ROUTE53":
            subnet_ranges.append(prefix['ip_prefix'])

    return subnet_ranges

def iptables_aws_range_list(ranges):
    subnet_ranges = list()
    for prefix in ranges['prefixes']:
        if prefix['service'] == "AMAZON":
            subnet_ranges.append(prefix['ip_prefix'])

    return subnet_ranges

def print_plain_ec2_list():
    print "Current AWS EC2 PUBLIC IP Ranges"
    print "----------------------------------"
    for line in plain_ec2_range_list(dictionary):
        cidr = IPNetwork(line)
        netmask = cidr.netmask
        network = cidr.network
        print network, netmask

def print_plain_rt53_list():
    print "Current AWS ROUTE53 PUBLIC IP Ranges"
    print "----------------------------------"
    for line in plain_rt53_range_list(dictionary):
        cidr = IPNetwork(line)
        netmask = cidr.netmask
        network = cidr.network
        print network, netmask

def print_plain_aws_list():
    print "Current AWS AMAZON PUBLIC IP Ranges"
    print "----------------------------------"
    for line in plain_aws_range_list(dictionary):
        cidr = IPNetwork(line)
        netmask = cidr.netmask
        network = cidr.network
        print network, netmask

def print_iptables_ec2_list():
    print "remark --------------------------------"
    print "remark Auto Generated AWS EC2 PUBLIC IP Ranges"
    for line in iptables_ec2_range_list(dictionary):
        cidr = IPNetwork(line)
        netmask = cidr.netmask
        network = cidr.network
        list_entry = "permit ip any any %s %s" % (network, netmask)
        print (list_entry)

def print_iptables_rt53_list():
    print "remark --------------------------------"
    print "remark Auto Generated AWS ROUTE53 PUBLIC IP Ranges"
    for line in iptables_rt53_range_list(dictionary):
        cidr = IPNetwork(line)
        netmask = cidr.netmask
        network = cidr.network
        list_entry = "permit ip any any %s %s" % (network, netmask)
        print (list_entry)

def print_iptables_aws_list():
    print "remark --------------------------------"
    print "remark Auto Generated AWS AMAZON PUBLIC IP Ranges"
    for line in iptables_aws_range_list(dictionary):
        cidr = IPNetwork(line)
        netmask = cidr.netmask
        network = cidr.network
        list_entry = "permit ip any any %s %s" % (network, netmask)
        print (list_entry)

def ec2_plain(parsed_args):
    print_plain_ec2_list()

def rt53_plain(parsed_args):
    print_plain_rt53_list()

def aws_plain(parsed_args):
    print_plain_aws_list()

def ec2_iptables(parsed_args):
    print_iptables_ec2_list()

def rt53_iptables(parsed_args):
    print_iptables_rt53_list()

def aws_iptables(parsed_args):
    print_iptables_aws_list()

parser = argparse.ArgumentParser()

parser.add_argument('--ec2-plain', help="Print Plain AWS EC2 Public Address Range List", dest='action', action='store_const', const=ec2_plain)
parser.add_argument('--rt53-plain', help="Print Plain AWS ROUTE53 Public Address Range List", dest='action', action='store_const', const=rt53_plain)
parser.add_argument('--aws-plain', help="Print Plain AWS AMAZON Public Address Range List", dest='action', action='store_const', const=aws_plain)
parser.add_argument('--ec2-iptables', help="Print IPTables formatted AWS EC2 Public Address Range List", dest='action', action='store_const', const=ec2_iptables)
parser.add_argument('--rt53-iptables', help="Print IPTables formatted AWS ROUTE53 Public Address Range List", dest='action', action='store_const', const=rt53_iptables)
parser.add_argument('--aws-iptables', help="Print IPTables formatted AWS AMAZON Public Address Range List (All Blocks)", dest='action', action='store_const', const=aws_iptables)

parsed_args = parser.parse_args()
if parsed_args.action is None:
    parser.parse_args(['-h'])
parsed_args.action(parsed_args)
