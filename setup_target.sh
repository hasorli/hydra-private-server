#!/bin/bash

VPN_MY_IP="${1}"
VPN_NETMASK="${2}"

FASTD_DATA=$(fastd --generate-key 2>/dev/null)
MY_PRIVATE_KEY=$(echo $FASTD_DATA|awk '{print $2}')
MY_PUBLIC_KEY=$(echo $FASTD_DATA|awk '{print $4}')

cat >config.sh <<EOL

MY_PRIVATE_KEY="${MY_PRIVATE_KEY}"
MY_PUBLIC_KEY="${MY_PUBLIC_KEY}"

VPN_MY_IP="${VPN_MY_IP}"
VPN_NETMASK="${VPN_NETMASK}"

EOL

cat >fastd.conf <<EOL

# Log warnings and errors to stderr
log level fatal;

# Set the interface name
interface "hydra";

# Support salsa2012+umac and null methods, prefer salsa2012+umac
method "salsa2012+umac";

# Secret key generated by 'fastd --generate-key'
secret "${MY_PRIVATE_KEY}";
# Public: ${MY_PUBLIC_KEY}

# Set the interface MTU for TAP mode with xsalsa20/aes128 over IPv4 with a base MTU of 1492 (PPPoE)
# (see MTU selection documentation)
mtu 1194;
mode tap;

# Include peers from the directory 'peers'
include peers from "peers";

on up sync "ifconfig hydra ${VPN_MY_IP} netmask ${VPN_NETMASK} up";
on down sync "ifconfig hydra down";

EOL

echo 1 >peercount

