# উবুন্টু ২৪.০৪ (Noble Numbat) - একদম লেটেস্ট
FROM ubuntu:24.04

# পপ-আপ বন্ধ রাখা
ENV DEBIAN_FRONTEND=noninteractive

# ২৪.০৪ এর নতুন রিপোজিটরি ফরম্যাট অনুযায়ী মিরর সেটআপ
RUN echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 && \
    sed -i 's/archive.ubuntu.com/mirrors.kernel.org/g' /etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's/security.ubuntu.com/mirrors.kernel.org/g' /etc/apt/sources.list.d/ubuntu.sources

# ধাপ ১: প্রয়োজনীয় টুলস
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git sudo nano openssh-server ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ধাপ ২: Tailscale ইনস্টল
RUN curl -fsSL https://tailscale.com/install.sh | sh

# ধাপ ৩: SSH কনফিগারেশন (UID ১০১০ ব্যবহার করা হয়েছে কনফ্লিক্ট এড়াতে)
RUN mkdir -p /var/run/sshd && \
    useradd -m -u 1010 devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "devuser:123456" | chpasswd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ধাপ ৪: ttyd ডাউনলোড
RUN wget -O /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# স্টার্টআপ ফাইল
COPY start.sh /start.sh
RUN chmod +x /start.sh

# ইউজার সুইচ করা
USER devuser
WORKDIR /home/devuser

CMD ["/start.sh"]
