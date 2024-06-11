### README.md

## Speedtest Script

### What the Script Does
- Runs an internet speed test using `speedtest-cli`.
- Parses the JSON response to extract download and upload speeds, latency, and packet loss.
- Converts the speeds to Mbps.
- Sends the results to a specified server if the download speed is acceptable.
- Path to file is : /usr/local/bin/speedtest.sh

### Docker Instructions
1. **Create the Dockerfile**: Use the provided Dockerfile to set up the environment.


2. **Build the Docker Image**:
    ```sh
    docker build -t speedtest-cron .
    ```

3. **Run the Docker Container**:
    ```sh
    docker run -d --name speedtest-container speedtest-cron
    ```

4. **Replace URL in Script**:
    - Ensure you replace the URL in the `speedtest.sh` script with your destination URL for sending the response.

### Check the Logs

To verify that the cron job is running, check the log files inside the Docker container.

- **Check the cron log**:
  ```sh
  docker exec -it speedtest-container cat /var/log/cron.log
  ```

- **Check the speedtest log**:
  ```sh
  docker exec -it speedtest-container cat /var/log/speedtest.log
  ```

These logs will show if the script is being executed and if there are any errors. By checking the timestamps and content, you can confirm whether the cron job is running as expected.
