#!/bin/bash
# ==============================================
# Script: fix-resolv.sh
# Author: Eki Guistian Leo Ganteng
# ==============================================
# Fungsi:
# - Ganti resolver bawaan (1.1.1.1 / 8.8.8.8) ke 127.0.0.1
# - Nonaktifkan systemd-resolved symlink agar resolv.conf bisa di-edit manual
# ==============================================

set -e

echo "=== Fix resolv.conf untuk gunakan DNS lokal (127.0.0.1) ==="

# Matikan systemd-resolved agar resolv.conf tidak di-overwrite
systemctl stop systemd-resolved
systemctl disable systemd-resolved

# Hapus symlink lama
if [ -L /etc/resolv.conf ]; then
    rm -f /etc/resolv.conf
fi

# Tulis resolv.conf baru
cat >/etc/resolv.conf <<EOF
nameserver 127.0.0.1
# fallback external DNS (opsional, uncomment jika perlu)
# nameserver 1.1.1.1
# nameserver 8.8.8.8
EOF

echo "✅ resolv.conf sudah diganti ke 127.0.0.1"
echo ">>> Coba test dengan: dig google.com @127.0.0.1"
