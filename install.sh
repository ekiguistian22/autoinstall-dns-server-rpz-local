#!/bin/bash
# =====================================================
# Script by - Eki Guistian Leo Ganteng
# =====================================================
# BIND9 / named Caching DNS + RPZ Blocklist + Whitelist
# Fitur:
# - Autoupdate Blocklist (StevenBlack hosts)
# - Whitelist custom (default google.com)
# - Blacklist custom (default xnxx.com)
# - Logging lengkap + Logrotate
# - Alerts (Email SMTP)
# - Auto-backup harian konfigurasi
# - Watchdog via cron
# - Install / Uninstall mode
# - SMTP fix: mail.sasfiber.com
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
    2>/dev/null || true

  echo "✅ Backup selesai -> $BACKUP_FILE"

  systemctl stop $DNS_SERVICE 2>/dev/null || true
  apt purge -y bind9 bind9-utils bind9-dnsutils dnsutils msmtp msmtp-mta mailutils || true
  apt autoremove -y

  rm -rf /etc/bind /var/cache/bind /var/log/named /var/log/dns-security \
         /etc/logrotate.d/bind9 /etc/msmtprc /etc/dns-alert-email.conf \
         /usr/local/bin/dns-*.sh \
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

read -p "Masukkan email admin penerima alert: " ADMIN_EMAIL

echo "=== [1/12] Update & Upgrade System ==="
apt update -y && apt upgrade -y

echo "=== [2/12] Install Packages ==="
apt install -y bind9 bind9-utils dnsutils logrotate curl wget msmtp msmtp-mta mailutils ca-certificates

echo "=== [2b/12] Validasi Instalasi Paket ==="
if ! command -v named >/dev/null 2>&1; then
  echo "❌ ERROR: Bind9 gagal terinstall! Silakan cek repository apt atau koneksi internet."
  exit 1
fi

if ! command -v dig >/dev/null 2>&1; then
  echo "❌ ERROR: dnsutils gagal terinstall! Pastikan paket dnsutils tersedia di repositori."
  exit 1
fi

if ! command -v mail >/dev/null 2>&1; then
  echo "⚠️ WARNING: mailutils tidak ditemukan, fitur alert email mungkin tidak jalan."
fi

echo "✅ Validasi selesai, semua paket utama tersedia."

echo "=== [3/12] Konfigurasi named.conf.options ==="
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

echo "=== [4/12] Konfigurasi Logging ==="
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

echo "=== [5/12] Konfigurasi logrotate ==="
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

echo "=== [6/12] Setup RPZ Blocklist & Whitelist ==="
mkdir -p $RPZ_DIR
cat >$RPZ_DIR/whitelist.txt <<EOF
# Default whitelist
google.com
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
xnxx.com        CNAME   .
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

# append into blacklist
cp $BL_FILE ${BL_FILE}.bak

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
systemctl reload bind9 || systemctl reload named
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

echo "=== [7/12] Setup SMTP Email Alert ==="
cat >/etc/msmtprc <<EOF
defaults
auth           on
tls            on
tls_starttls   off
tls_trust_file /etc/ssl/certs/ca-certificates.crt
account        default
host           mail.sasfiber.com
port           465
from           noreply@sasfiber.com
user           noreply@sasfiber.com
password       Donotdistrub@2208
EOF
chmod 600 /etc/msmtprc

cat >/etc/dns-alert-email.conf <<EOF
ALERT_EMAIL="${ADMIN_EMAIL}"
EOF

echo "=== [8/12] Buat Script Alert & Backup ==="
mkdir -p "$BACKUP_DIR"

# --- Common Alert Script ---
cat >/usr/local/bin/dns-send-alert.sh <<'EOF'
#!/bin/bash
MSG="$1"

if [[ -f /etc/dns-alert-email.conf ]]; then
  source /etc/dns-alert-email.conf
  echo "$MSG" | mail -s "[DNS ALERT] $(hostname)" "$ALERT_EMAIL"
fi
EOF
chmod +x /usr/local/bin/dns-send-alert.sh

# --- Auto Backup Script ---
cat >/usr/local/bin/dns-backup.sh <<EOF
#!/bin/bash
TIMESTAMP=\$(date +"%Y%m%d")
FILE="$BACKUP_DIR/dns-backup-\$TIMESTAMP.tar.gz"
tar -czf "\$FILE" /etc/bind /var/log/named /var/log/dns-security /etc/msmtprc \
  /etc/dns-alert-email.conf 2>/dev/null || true
EOF
chmod +x /usr/local/bin/dns-backup.sh

echo "=== [9/12] Enable & Start DNS Service ($DNS_SERVICE) ==="
systemctl enable $DNS_SERVICE
systemctl restart $DNS_SERVICE
systemctl status $DNS_SERVICE --no-pager || true

echo "=== [10/12] Crontab Watchdog, Backup & Blocklist Update ==="
(crontab -l 2>/dev/null; cat <<EOF
*/5 * * * * systemctl is-active --quiet $DNS_SERVICE || systemctl restart $DNS_SERVICE
30 0 * * * /usr/local/bin/dns-backup.sh
15 3 * * * /usr/local/bin/dns-update-blocklist.sh
EOF
) | crontab -

echo "=== [11/12] Update Blocklist Sekarang ==="
/usr/local/bin/dns-update-blocklist.sh

echo "=== [12/12] Tes DNS ==="
echo ">>> Test google.com (harus resolve)"
dig +short google.com @127.0.0.1 || true
echo
echo ">>> Test xnxx.com (harus blocked)"
dig +short xnxx.com @127.0.0.1 || true

echo "=== Selesai ==="
echo "✅ $DNS_SERVICE sudah jalan dengan whitelist google.com & block xnxx.com"
