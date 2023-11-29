#!/bin/sh

if test -d /proc/sys/net/ipv4/conf/*vpn; then
    basename /proc/sys/net/ipv4/conf/*vpn | xargs pkexec wg-quick down
else
    pkexec wg-quick up racknerd_vpn
fi
