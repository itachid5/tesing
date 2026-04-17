FROM ubuntu:22.04

# ইনস্টলেশনের সময় যেকোনো পপ-আপ বন্ধ করা
ENV DEBIAN_FRONTEND=noninteractive

# Kernel.org এর সুপার ফাস্ট মিরর ব্যবহার করা এবং IPv4 ফোর্স করা
RUN echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 && \
    sed -i 's/archive.ubuntu.com/mirrors.kernel.org/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.kernel.org/g' /etc/apt/sources.list

# ধাপ ১: শুধু বেসিক টুলস এবং SSH
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git sudo nano openssh-server ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ধাপ ২: Tailscale ইনস্টল
RUN curl -fsSL https://tailscale.com/install.sh | sh

# ধাপ ৩: SSH কনফিগারেশন এবং পোর্ট ২২ ওপেন
RUN mkdir -p /var/run/sshd && \
    useradd -m -u 1000 devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "devuser:123456" | chpasswd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ধাপ ৪: Render-এর জন্য ttyd
RUN wget -O /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# স্টার্টআপ স্ক্রিপ্ট
COPY start.sh /start.sh
RUN chmod +x /start.sh

USER devuser
WORKDIR /home/devuser

CMD ["/start.sh"]
