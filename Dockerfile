FROM ubuntu:22.04

# প্রয়োজনীয় প্যাকেজ এবং Tailscale ইনস্টলেশন
RUN apt-get update && apt-get install -y \
    curl wget git sudo nano openssh-server \
    && curl -fsSL https://tailscale.com/install.sh | sh \
    && rm -rf /var/lib/apt/lists/*

# পোর্ট 22 এ স্ট্যান্ডার্ড SSH সেটআপ এবং ইউজার তৈরি
RUN mkdir /var/run/sshd && \
    useradd -m -u 1000 devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "devuser:123456" | chpasswd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ওয়েব টার্মিনাল ব্যাকআপের জন্য ttyd
RUN wget -O /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# স্টার্টআপ স্ক্রিপ্ট তৈরি (SSH এবং Tailscale রান করার জন্য)
RUN echo "#!/bin/bash" > /start.sh && \
    echo "sudo service ssh start" >> /start.sh && \
    echo "sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &" >> /start.sh && \
    echo "sleep 3" >> /start.sh && \
    echo "if [ -n \"\$TAILSCALE_AUTHKEY\" ]; then" >> /start.sh && \
    echo "    sudo tailscale up --authkey=\${TAILSCALE_AUTHKEY} --hostname=hf-ubuntu-workspace" >> /start.sh && \
    echo "fi" >> /start.sh && \
    echo "ttyd -p 7860 -W bash" >> /start.sh && \
    chmod +x /start.sh

USER devuser
ENV HOME=/home/devuser
WORKDIR $HOME

EXPOSE 7860 22

CMD ["/start.sh"]
