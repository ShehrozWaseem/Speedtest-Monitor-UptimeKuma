#!/bin/bash

# Get the JSON response from speedtest
LOGFILE="/var/log/speedtest.log"
JSON_LOGFILE="/var/log/speedtest.json"

response=$(speedtest --accept-license -p no --format json-pretty)

# Append the raw JSON response to the log file
echo "$response" >> $LOGFILE

# Parse the JSON response and extract relevant values
timestamp=$(echo "$response" | jq -r '.timestamp')
download_bandwidth=$(echo "$response" | jq -r '.download.bandwidth')
upload_bandwidth=$(echo "$response" | jq -r '.upload.bandwidth')
url=$(echo "$response" | jq -r '.result.url')
latency=$(echo "$response" | jq -r '.ping.latency')
loss=$(echo "$response" | jq -r '.packetLoss')
sv=$(echo "$response" | jq -r '.isp')
if [[ $sv == *" "* ]]; then
    # Value contains a space, remove it
    sv=$(echo "$sv" | tr -d ' ')
fi

# Calculate download and upload speeds in Mbps
download=$(echo "scale=2; $download_bandwidth / 125000" | bc)
upload=$(echo "scale=2; $upload_bandwidth / 125000" | bc)

# Prepare the log entry in JSON format
log_entry=$(jq -n \
                  --arg url "$url" \
                  --arg isp "$isp" \
                  --arg download "$download" \
                  --arg upload "$upload" \
                  --arg latency "$latency" \
                  --arg loss "$loss" \
                  '{url: $url, isp: $isp, download: $download, upload: $upload, latency: $latency, packetLoss: $loss}')

# Check if the JSON log file exists
if [ ! -f $JSON_LOGFILE ]; then
    echo "{}" > $JSON_LOGFILE
fi

# Add the new log entry to the JSON log file
jq --arg timestamp "$timestamp" --argjson log_entry "$log_entry" '.[$timestamp] = $log_entry' $JSON_LOGFILE > tmp.$$.json && mv tmp.$$.json $JSON_LOGFILE
echo "testhshdh"
echo $log_entry
# Check if download speed is acceptable
acceptable=0
if (( $(echo "$download > $acceptable" | bc -l) )); then
    echo "shell in if"
    echo "Test passed. Sending data to server." >> $LOGFILE
    if curl -k -s "http://192.168.100.254:3001/api/push/ldPTbaH7Xp?status=up&msg=sv:$sv-download:$download-upload:$upload&ping=$latency" > /dev/null; then
        echo "Curl request successful" >> $LOGFILE
    else
        echo "Curl request failed" >> $LOGFILE
    fi
else
    echo "Download speed not acceptable. No data sent." >> $LOGFILE
fi

