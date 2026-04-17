#!/bin/bash
set -e

sudo /usr/sbin/sshd
sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
sleep 3

if [ -n "$TAILSCALE_AUTHKEY" ]; then
  sudo tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname=railway-box
fi

tail -f /dev/null
