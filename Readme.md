# Server Health Monitor

A simple script to monitor your Linux server and send email reports via Gmail.

## Features

- Checks **uptime, CPU, memory, disk usage, top processes, and network info**
- Sends **email reports** via Gmail (`msmtp`)
- Displays report in terminal
- Runs automatically via **cron**:
  - Every 5 minutes
  - Every hour

## Setup

1. Make installer executable:

```bash
chmod +x ~/full_setup_server_monitor_msmtp_cron.sh

2. Run the installer:

~/full_setup_server_monitor_msmtp_cron.sh


Enter your Gmail and App Password when prompted.

3. Test the script:

~/full_mini_monitor_pretty_msmtp.sh

- You should see the full server health report in the terminal.

- An email should be delivered to your Gmail.




Author:

Ajith Kumar!
