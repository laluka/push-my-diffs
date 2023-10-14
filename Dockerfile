# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Run system updates and install packages
RUN apt-get update && \
    apt-get install -y git bash curl python3 python3-venv python3-pip nodejs npm chromium-bsu && \
    apt-get install -y libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2 && \
    npm install svgexport -g && \
    pip install ansitoimg \
    && rm -rf /var/lib/apt/lists/*

# RUN pip install ansitoimg svgexport

# Copy the script into the container
COPY push-my-diffs.sh /usr/local/bin/push-my-diffs.sh

# Make the script executable
RUN chmod +x /usr/local/bin/push-my-diffs.sh

# Setup a working directory
WORKDIR /opt/sources

# Your .py3 virtual environment setup and other configuration can go here

# CMD or ENTRYPOINT to run your script
CMD ["/usr/local/bin/push-my-diffs.sh"]
