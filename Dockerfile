FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

RUN apt-get update && apt-get install -y \
    openssh-server sudo curl wget git nano \
    && curl -fsSL https://tailscale.com/install.sh | sh \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd && \
    useradd -m -s /bin/bash -u 1000 devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "devuser:123456" | chpasswd && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

RUN cat > /start.sh <<'SH'
#!/bin/bash
set -e
sudo /usr/sbin/sshd
sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
sleep 3
if [ -n "$TAILSCALE_AUTHKEY" ]; then
  sudo tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname=railway-box
fi
tail -f /dev/null
SH

RUN chmod +x /start.sh

USER devuser
WORKDIR /home/devuser

EXPOSE 22

CMD ["/start.sh"]
