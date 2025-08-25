#!/bin/bash
# ==============================================
# Script: fix-resolv.sh (Interactive)
# Author: Eki Guistian Leo Ganteng
# ==============================================
# Fungsi:
# - Atur resolv.conf agar pakai DNS lokal (127.0.0.1)
# - Balikin resolv.conf ke default (Cloudflare + Google DNS)
# ==============================================

set -e

# Pastikan systemd-resolved dimatikan supaya resolv.conf tidak auto-overwrite
systemctl stop systemd-resolved 2>/dev/null || true
systemctl disable systemd-resolved 2>/dev/null || true

# Hapus symlink resolv.conf jika ada
if [ -L /etc/resolv.conf ]; then
    rm -f /etc/resolv.conf
fi

echo "======================================"
echo "   FIX RESOLV.CONF - PILIH MODE"
echo "======================================"
echo "1) Pakai DNS lokal (127.0.0.1)"
echo "2) Balik ke DNS default (1.1.1.1 + 8.8.8.8)"
echo "3) Keluar"
echo "======================================"
read -p "Pilih opsi [1-3]: " OPT

case "$OPT" in
  1)
    echo "=== Set resolv.conf ke 127.0.0.1 ==="
    cat >/etc/resolv.conf <<EOF
nameserver 127.0.0.1
EOF
    echo "✅ Sekarang semua query DNS resolve ke server lokal (127.0.0.1)"
    ;;

  2)
    echo "=== Set resolv.conf ke default DNS (Cloudflare + Google) ==="
    cat >/etc/resolv.conf <<EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
    echo "✅ resolv.conf sudah balik ke default (1.1.1.1 & 8.8.8.8)"
    ;;

  3)
    echo "Keluar..."
    exit 0
    ;;

  *)
    echo "❌ Pilihan tidak valid"
    exit 1
    ;;
esac

echo
echo ">>> Tes dengan: dig google.com"
