#!/bin/bash
# full_setup_server_monitor_msmtp.sh
# Automated installer for server health script with Gmail msmtp and dual cron jobs

# ----------------------------
# 1️⃣ Ask for Gmail email and app password
# ----------------------------
read -p "Enter your Gmail address: " EMAIL
read -sp "Enter your Gmail App Password: " APP_PASS
echo

# ----------------------------
# 2️⃣ Update and install packages
# ----------------------------
echo "🔄 Updating package lists..."
if command -v apt &> /dev/null; then
    sudo apt update -y
    sudo apt install -y msmtp net-tools
elif command -v yum &> /dev/null; then
    sudo yum check-update -y
    sudo yum install -y msmtp net-tools
else
    echo "❌ Unsupported package manager. Install msmtp and net-tools manually."
    exit 1
fi

# ----------------------------
# 3️⃣ Configure msmtp
# ----------------------------
MSMTP_CONFIG="$HOME/.msmtprc"
echo "🛠️ Configuring msmtp..."
cat > $MSMTP_CONFIG <<EOL
# Gmail SMTP configuration
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           $EMAIL
user           $EMAIL
password       $APP_PASS

account default : gmail
EOL
chmod 600 $MSMTP_CONFIG
echo "✅ msmtp configured."

# ----------------------------
# 4️⃣ Create the server health script
# ----------------------------
SCRIPT_PATH="$HOME/full_mini_monitor_pretty_msmtp.sh"
echo "📝 Creating the server health script at $SCRIPT_PATH..."

cat > $SCRIPT_PATH <<EOL
#!/bin/bash
TO="$EMAIL"
SUBJECT="🌟 Full Server Health Report - \$(date '+%Y-%m-%d %H:%M:%S')"
TEMP_FILE="/tmp/full_server_health_report.txt"

echo "🌐=========================================🌐" | tee \$TEMP_FILE
echo "           🚀 SERVER HEALTH REPORT 🚀       " | tee -a \$TEMP_FILE
echo "🌐=========================================🌐" | tee -a \$TEMP_FILE

echo -e "\n🕒 1️⃣ Server Uptime:" | tee -a \$TEMP_FILE
uptime | tee -a \$TEMP_FILE

echo -e "\n💽 2️⃣ Disk Usage:" | tee -a \$TEMP_FILE
df -h | tee -a \$TEMP_FILE

echo -e "\n🧠 3️⃣ Memory Usage:" | tee -a \$TEMP_FILE
free -h | tee -a \$TEMP_FILE

echo -e "\n⚡ 4️⃣ CPU Usage:" | tee -a \$TEMP_FILE
top -bn1 | grep "Cpu(s)" | tee -a \$TEMP_FILE

echo -e "\n🔥 5️⃣ Top 5 Processes by CPU:" | tee -a \$TEMP_FILE
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 | tee -a \$TEMP_FILE

echo -e "\n💾 6️⃣ Top 5 Processes by Memory:" | tee -a \$TEMP_FILE
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 | tee -a \$TEMP_FILE

echo -e "\n🌐 7️⃣ Network Statistics (IP):" | tee -a \$TEMP_FILE
if command -v ip &> /dev/null; then
    ip -brief addr show | grep -v "lo" | tee -a \$TEMP_FILE
else
    echo "❌ 'ip' command not found" | tee -a \$TEMP_FILE
fi

echo -e "\n✅ Mini Automation Completed by Ajithkumar from Xops! Have a great day! 🚀" | tee -a \$TEMP_FILE
echo "🌐=========================================🌐" | tee -a \$TEMP_FILE

# Send email via msmtp
if command -v msmtp &> /dev/null; then
    msmtp "\$TO" < \$TEMP_FILE && echo "📧 Email sent via msmtp to \$TO" || echo "❌ Failed to send email via msmtp"
else
    echo "⚠️ msmtp not found. Install msmtp to enable email notifications."
fi

rm \$TEMP_FILE
EOL

# ----------------------------
# 5️⃣ Make script executable
# ----------------------------
chmod +x $SCRIPT_PATH
echo "✅ Server health script created and made executable."

# ----------------------------
# 6️⃣ Add dual cron jobs
# ----------------------------
(crontab -l 2>/dev/null; echo "*/5 * * * * $SCRIPT_PATH") | crontab -
(crontab -l 2>/dev/null; echo "0 * * * * $SCRIPT_PATH") | crontab -
echo "⏰ Cron jobs scheduled: every 5 minutes and every hour."

echo "🎉 Installation complete! Your server health report will be emailed to $EMAIL."
echo "📧 Test it now by running: $SCRIPT_PATH"
