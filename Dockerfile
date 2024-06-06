FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl jq cron nano && \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get update && \
    apt-get install speedtest && \
    apt-get install bc

# Create log directory
RUN mkdir -p /var/log

# Create cron job file
RUN echo "* * * * * root /usr/local/bin/speedtest.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/speedtest-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/speedtest-cron

# Copy the script into the container
COPY speedtest.sh /usr/local/bin/speedtest.sh

# Set execute permission for the script
RUN chmod +x /usr/local/bin/speedtest.sh

# Start cron service
CMD ["cron", "-f"]
