<p align="center">
  <img src="https://img.shields.io/badge/Project-BIND9%20Auto%20Installer-blue?style=for-the-badge&logo=linux" />
  <img src="https://img.shields.io/badge/License-GPL.3.0-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Maintained-Yes-success?style=for-the-badge" />
</p>

<h1 align="center">🚀 BIND9 DNS Server Auto Installer</h1>

<p align="center">
  <i>Auto installer & management script untuk BIND9 dengan blocklist, whitelist, alert, backup, dan security monitoring.</i>
</p>

---

# 🚀 BIND9 DNS Server Auto Installer

Script otomatis untuk instalasi **BIND9 DNS Server** dengan fitur lengkap:

- ✅ DNS Caching + Forwarder
- ✅ Blocklist otomatis (StevenBlack Hosts via RPZ)
- ✅ Whitelist support
- ✅ Logging & Security Monitoring
- ✅ Email Alerts (SMTP)
- ✅ Telegram Alerts (Bot API)
- ✅ Auto Backup Harian
- ✅ Watchdog Service (auto restart jika mati)
- ✅ Uninstaller dengan Auto Backup

---

## 📌 Cara Pemakaian

### Instalasi
```bash
# masuk sebagai root
sudo su
git clone https://github.com/ekiguistian22/autoinstall-dns-server-rpz-local
cd autoinstall-dns-server-rpz-local
chmod +x install.sh
bash install.sh
```

- Masukkan subnet internal yang boleh query
- Input manual email penerima untuk alert
- Input manual Telegram Bot Token & Chat ID
- Pilih opsi instalasi

### Uninstall
```bash
bash install.sh
# Pilih opsi (2) Uninstall
```

---

## 📂 Struktur Backup
Backup otomatis tersimpan di:
```
/root/dns-backup/dns-backup-YYYYMMDD.tar.gz
```

---

## 🔔 Alerts
- Email via SMTP (custom)
- Telegram via Bot API
- Security log alert setiap jam

---

## 💡 Blocklist + Whitelist
- Blocklist otomatis update dari **StevenBlack Hosts** → dikonversi ke RPZ
- Whitelist manual bisa ditambahkan di `/etc/bind/whitelist.rpz`

---
## 💡 Jika Server DNS kamu belum resolve ke localhost ketika di cek menggunakan dig / nslookup. Coba ikuti langkah-langkah dibawah ini
Solusi: Pastikan server resolve ke DNS lokal (127.0.0.1)

1. Edit konfigurasi Netplan  
Cek file konfigurasi Netplan (biasanya ada di `/etc/netplan/01-netcfg.yaml` atau `/etc/netplan/50-cloud-init.yaml`):

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

Cari bagian:
```yaml
nameservers:
  addresses: [1.1.1.1,8.8.8.8]
```

Ganti jadi:
```yaml
nameservers:
  addresses: [127.0.0.1]
```

(bisa juga `[127.0.0.1, ::1]` untuk support IPv6 lokal).

Simpan lalu apply:
```bash
sudo netplan apply
```

2. Lock resolv.conf agar tidak di-overwrite  
Kadang `cloud-init` atau `systemd-resolved` akan overwrite `/etc/resolv.conf`.  
Untuk pastikan resolv pakai lokal:

```bash
sudo rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
```

`chattr +i` = file jadi immutable, tidak bisa diubah service lain.

3. Restart service networking & DNS
```bash
sudo systemctl restart systemd-resolved
sudo systemctl restart bind9 || sudo systemctl restart named
```

✅ Cek apakah sudah resolve ke lokal

Jalankan:
```bash
dig google.com @127.0.0.1
```

Kalau dapat respon cepat (dan muncul `SERVER: 127.0.0.1#53`), berarti sudah lewat BIND9 lokal.

Untuk pastikan default resolver juga pakai lokal:
```bash
dig google.com
```

Harusnya hasilnya juga keluar dari `127.0.0.1#53`.

---

## ❤️ Support Project Ini
Kalau script ini bermanfaat, kamu bisa traktir kopi ☕ lewat PayPal:  

👉 [paypal.me/ekiguistian](https://www.paypal.me/ekiguistian22)

Atau scan QR berikut:  
![PayPal QR](paypal_qr_ekiguistian22.png)

---

✍️ Created with ❤️ by **Leo Ganteng**

---

<p align="center">
  ❤️ Created by <b>Leo Ganteng</b> | 
  ☕ Support me via <a href="https://www.paypal.me/ekiguistian22">PayPal</a>
</p>

<p align="center">
  <a href="https://github.com/ekiguistian">
    <img src="https://img.shields.io/github/followers/ekiguistian?label=Follow%20me&style=social" alt="GitHub Follow" />
  </a>
  <a href="https://github.com/ekiguistian?tab=repositories">
    <img src="https://img.shields.io/badge/More%20Projects-GitHub-orange?style=flat-square" />
  </a>
</p>
