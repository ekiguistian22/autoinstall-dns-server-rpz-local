#!/bin/bash
# =====================================================
# Script by - Eki Guistian Leo Ganteng
# =====================================================
# BIND9 / named Caching DNS + RPZ Blocklist + Whitelist
# Fitur:
# - Autoupdate Blocklist (StevenBlack hosts)
# - Whitelist custom
# - Logging lengkap + Logrotate
# - Alerts (Email SMTP / Telegram)
# - Auto-backup harian konfigurasi
# - Watchdog via cron
# - Install / Uninstall mode
# =====================================================

set -e

FORWARDERS="103.88.88.88 103.88.88.99 203.119.13.77 203.119.13.78"
BACKUP_DIR="/root/dns-backup"
RPZ_DIR="/etc/bind/blacklist"

# --- Detect service name ---
if systemctl list-unit-files | grep -q "^named.service"; then
  DNS_SERVICE="named"
else
  DNS_SERVICE="bind9"
fi

echo "=== MENU DNS SCRIPT ==="
echo "1) Install / Konfigurasi DNS ($DNS_SERVICE)"
echo "2) Uninstall DNS + Backup + Bersihkan konfigurasi"
read -p "Pilih opsi (1/2): " OPT

if [[ "$OPT" == "2" ]]; then
  echo "=== Uninstall DNS & backup konfigurasi ==="
  TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
  BACKUP_FILE="$BACKUP_DIR/dns-backup-$TIMESTAMP.tar.gz"
  mkdir -p "$BACKUP_DIR"

  echo "Membuat backup konfigurasi & log ke $BACKUP_FILE ..."
  tar -czf "$BACKUP_FILE" \
    /etc/bind \
    /var/log/named \
    /var/log/dns-security \
    /etc/msmtprc \
    /etc/dns-alert-email.conf \
    /etc/dns-alert-telegram.conf \
    2>/dev/null || true

  echo "✅ Backup selesai -> $BACKUP_FILE"

  systemctl stop $DNS_SERVICE 2>/dev/null || true
  apt purge -y bind9 bind9-utils bind9-dnsutils dnsutils msmtp msmtp-mta mailutils || true
  apt autoremove -y

  rm -rf /etc/bind /var/cache/bind /var/log/named /var/log/dns-security \
         /etc/logrotate.d/bind9 /etc/msmtprc /etc/dns-alert-email.conf \
         /etc/dns-alert-telegram.conf /usr/local/bin/dns-*.sh \
         /usr/local/bin/dns-backup.sh

  crontab -l 2>/dev/null | grep -v "dns-" | grep -v "dns-backup" | crontab - || true

  echo "✅ $DNS_SERVICE & konfigurasi sudah dihapus. Backup ada di $BACKUP_FILE"
  exit 0
fi

# === Instalasi ===

echo "=== Instalasi DNS Server ($DNS_SERVICE) ==="

# --- INPUTS ---
read -p "Masukkan subnet internal yang boleh query (default: 192.168.0.0/16 10.0.0.0/8 172.16.0.0/12 localhost): " SUBNETS
SUBNETS=${SUBNETS:-"192.168.0.0/16 10.0.0.0/8 172.16.0.0/12 localhost"}

read -p "Aktifkan Email Alert via SMTP? (y/N): " ENABLE_SMTP
ENABLE_SMTP=${ENABLE_SMTP:-N}

if [[ "${ENABLE_SMTP^^}" == "Y" ]]; then
  read -p "Email tujuan alert (contoh: admin@yourdomain.com): " ALERT_EMAIL
  read -p "SMTP server (contoh: smtp.yourdomain.com): " SMTP_SERVER
  read -p "SMTP port (default 587): " SMTP_PORT
  SMTP_PORT=${SMTP_PORT:-587}
  read -p "SMTP username (email login): " SMTP_USER
  read -s -p "SMTP password: " SMTP_PASS
  echo
fi

read -p "Aktifkan Telegram Alert? (y/N): " ENABLE_TG
ENABLE_TG=${ENABLE_TG:-N}

if [[ "${ENABLE_TG^^}" == "Y" ]]; then
  read -p "Telegram Bot Token (contoh: 123456:ABCDEF...): " TG_TOKEN
  read -p "Telegram Chat ID (contoh: 123456789 atau -100xxxxxxxxxx): " TG_CHAT_ID
fi

echo "=== [1/10] Update & Upgrade System ==="
apt update -y && apt upgrade -y

echo "=== [2/10] Install Packages ==="
apt install -y bind9 bind9-utils dnsutils logrotate curl wget
if [[ "${ENABLE_SMTP^^}" == "Y" ]]; then
  apt install -y msmtp msmtp-mta mailutils ca-certificates
fi

echo "=== [3/10] Konfigurasi named.conf.options ==="
cat >/etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { ${SUBNETS}; };

    forwarders {
        ${FORWARDERS// /; };
    };

    dnssec-validation auto;
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF

echo "=== [4/10] Konfigurasi Logging ==="
mkdir -p /var/log/named /var/log/dns-security
chown bind:bind /var/log/named /var/log/dns-security

cat >/etc/bind/named.conf.logging <<EOF
logging {
    channel default_file { file "/var/log/named/default.log" versions 3 size 5m; severity info; print-time yes; };
    channel security_file { file "/var/log/dns-security/security.log" versions 3 size 5m; severity dynamic; print-time yes; };
    channel query_file { file "/var/log/named/queries.log" versions 3 size 20m; severity dynamic; print-time yes; };
    category default { default_file; };
    category security { security_file; };
    category queries { query_file; };
};
EOF

echo "=== [5/10] Konfigurasi logrotate ==="
cat >/etc/logrotate.d/bind9 <<EOF
/var/log/named/*.log /var/log/dns-security/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 bind bind
    sharedscripts
    postrotate
        systemctl reload $DNS_SERVICE >/dev/null 2>&1 || true
    endscript
}
EOF

echo "=== [6/10] Setup RPZ Blocklist & Whitelist ==="
mkdir -p $RPZ_DIR
cat >$RPZ_DIR/whitelist.txt <<EOF
# Example whitelist domains
gooddomain.com
safe-site.org
EOF

cat >$RPZ_DIR/blacklist.rpz <<EOF
\$TTL 2h
@       IN      SOA     localhost. root.localhost. (
                        2       ; serial
                        1d      ; refresh
                        2h      ; retry
                        4w      ; expire
                        1h )    ; minimum
        IN      NS      localhost.
EOF

# Update blacklist script
cat >/usr/local/bin/dns-update-blocklist.sh <<'EOF'
#!/bin/bash
RPZ_DIR="/etc/bind/blacklist"
BL_FILE="$RPZ_DIR/blacklist.rpz"

TMP=$(mktemp)
wget -qO- https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | \
grep "^0.0.0.0" | awk '{print $2}' | sort -u > $TMP

# skip whitelist
if [[ -f "$RPZ_DIR/whitelist.txt" ]]; then
  grep -v -f "$RPZ_DIR/whitelist.txt" $TMP > ${TMP}.f
  mv ${TMP}.f $TMP
fi

# generate RPZ
cat >$BL_FILE <<EOL
\$TTL 2h
@       IN      SOA     localhost. root.localhost. (
                        $(date +%s) ; serial
                        1d      ; refresh
                        2h      ; retry
                        4w      ; expire
                        1h )    ; minimum
        IN      NS      localhost.
EOL

while read d; do
  echo "$d CNAME ." >> $BL_FILE
done < $TMP

rm -f $TMP
systemctl reload $DNS_SERVICE
EOF
chmod +x /usr/local/bin/dns-update-blocklist.sh

cat >>/etc/bind/named.conf.local <<EOF
response-policy {
    zone "blacklist.rpz";
};
zone "blacklist.rpz" {
    type master;
    file "$RPZ_DIR/blacklist.rpz";
};
EOF

echo "=== [7/10] Buat Script Alert & Backup ==="
mkdir -p "$BACKUP_DIR"

# --- Alert Email ---
if [[ "${ENABLE_SMTP^^}" == "Y" ]]; then
cat >/etc/msmtprc <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
account        default
host           ${SMTP_SERVER}
port           ${SMTP_PORT}
from           ${SMTP_USER}
user           ${SMTP_USER}
password       ${SMTP_PASS}
EOF
chmod 600 /etc/msmtprc
cat >/etc/dns-alert-email.conf <<EOF
ALERT_EMAIL="${ALERT_EMAIL}"
EOF
fi

# --- Alert Telegram ---
if [[ "${ENABLE_TG^^}" == "Y" ]]; then
cat >/etc/dns-alert-telegram.conf <<EOF
TG_TOKEN="${TG_TOKEN}"
TG_CHAT_ID="${TG_CHAT_ID}"
EOF
fi

# --- Common Alert Script ---
cat >/usr/local/bin/dns-send-alert.sh <<'EOF'
#!/bin/bash
MSG="$1"

if [[ -f /etc/dns-alert-email.conf ]]; then
  source /etc/dns-alert-email.conf
  echo "$MSG" | mail -s "[DNS ALERT] $(hostname)" "$ALERT_EMAIL"
fi

if [[ -f /etc/dns-alert-telegram.conf ]]; then
  source /etc/dns-alert-telegram.conf
  curl -s -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
       -d chat_id="${TG_CHAT_ID}" \
       -d text="$(hostname): $MSG"
fi
EOF
chmod +x /usr/local/bin/dns-send-alert.sh

# --- Auto Backup Script ---
cat >/usr/local/bin/dns-backup.sh <<EOF
#!/bin/bash
TIMESTAMP=\$(date +"%Y%m%d")
FILE="$BACKUP_DIR/dns-backup-\$TIMESTAMP.tar.gz"
tar -czf "\$FILE" /etc/bind /var/log/named /var/log/dns-security /etc/msmtprc \
  /etc/dns-alert-email.conf /etc/dns-alert-telegram.conf 2>/dev/null || true
EOF
chmod +x /usr/local/bin/dns-backup.sh

echo "=== [8/10] Enable & Start DNS Service ($DNS_SERVICE) ==="
systemctl enable $DNS_SERVICE
systemctl restart $DNS_SERVICE
systemctl status $DNS_SERVICE --no-pager || true

echo "=== [9/10] Crontab Watchdog, Backup & Blocklist Update ==="
(crontab -l 2>/dev/null; cat <<EOF
*/5 * * * * systemctl is-active --quiet $DNS_SERVICE || systemctl restart $DNS_SERVICE
0 * * * * /usr/local/bin/dns-send-alert.sh "Hourly DNS check OK"
30 0 * * * /usr/local/bin/dns-backup.sh
15 3 * * * /usr/local/bin/dns-update-blocklist.sh
EOF
) | crontab -

echo "=== [10/10] Selesai ==="
echo "✅ $DNS_SERVICE sudah terinstall dengan forwarders: $FORWARDERS"
echo "✅ Subnet allowed: $SUBNETS"
echo "✅ Auto-backup harian aktif ke $BACKUP_DIR"
echo "✅ Blocklist otomatis update dari StevenBlack"
if [[ "${ENABLE_SMTP^^}" == "Y" ]]; then
  echo "✅ Email alert aktif -> $ALERT_EMAIL"
fi
if [[ "${ENABLE_TG^^}" == "Y" ]]; then
  echo "✅ Telegram alert aktif -> Chat ID $TG_CHAT_ID"
fi
