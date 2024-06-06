#!/bin/bash

# Get the JSON response from speedtest
LOGFILE="/var/log/speedtest.log"

response=$(speedtest --accept-license -p no --format json-pretty)

# Print the raw JSON response for debugging purposes
echo "Raw JSON response:"

echo "Raw JSON response:" >> $LOGFILE
echo "$response" >> $LOGFILE

# Parse the JSON response and extract relevant values
download_bandwidth=$(echo "$response" | jq -r '.download.bandwidth')
upload_bandwidth=$(echo "$response" | jq -r '.upload.bandwidth')
url=$(echo "$response" | jq -r '.result.url')
latency=$(echo "$response" | jq -r '.ping.latency')
loss=$(echo "$response" | jq -r '.packetLoss')

# Print the extracted raw bandwidth values for debugging purposes
echo "Extracted values:"
echo "Download Bandwidth: $download_bandwidth"
echo "Upload Bandwidth: $upload_bandwidth"

# Calculate download and upload speeds in Mbps
download=$(echo "scale=2; $download_bandwidth / 125000" | bc)
upload=$(echo "scale=2; $upload_bandwidth / 125000" | bc)

# Print the calculation steps for debugging purposes
echo "Calculation steps:"
echo "Download calculation: scale=2; $download_bandwidth / 125000"
echo "Upload calculation: scale=2; $upload_bandwidth / 125000"

# Print the final results
echo "Final results:"
echo "Download: $download Mbps"
echo "Upload: $upload Mbps"
echo "URL: $url"
echo "Latency: $latency ms"
echo "Packet Loss: $loss"

# Check if download speed is acceptable
acceptable=0
if (( $(echo "$download > $acceptable" | bc -l) )); then
    echo "Test passed. Sending data to server."
    if curl -k -s "http://192.168.100.254:3001/api/push/ldPTbaH7Xp?status=up&msg=$url&ping=$download" > /dev/null; then
        echo "Curl request successful"
    else
        echo "Curl request failed"
    fi
else
    echo "Download speed not acceptable. No data sent."
fi