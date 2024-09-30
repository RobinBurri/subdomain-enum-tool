FROM debian:latest

# Update and install basic tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    nmap \
    python3 \
    python3-pip \
    python3-venv \
    golang \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Go tools
RUN go install -v github.com/tomnomnom/assetfinder@latest
RUN go install -v github.com/owasp-amass/amass/v3/...@master
RUN go install -v github.com/tomnomnom/httprobe@latest
RUN go install -v github.com/haccer/subjack@latest
RUN go install -v github.com/tomnomnom/waybackurls@latest

# Set Go binary path
ENV PATH="/root/go/bin:${PATH}"

# Create a virtual environment and install EyeWitness
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && pip install eyewitness

# Clone EyeWitness repository
RUN git clone https://github.com/FortyNorthSecurity/EyeWitness.git /opt/EyeWitness
WORKDIR /opt/EyeWitness/Python/setup
RUN ./setup.sh

# Copy the script from the scripts directory
COPY scripts/theScript.sh /usr/local/bin/theScript.sh
RUN chmod +x /usr/local/bin/theScript.sh

# Set working directory
WORKDIR /workspace

# Set entrypoint
ENTRYPOINT ["/bin/bash"]