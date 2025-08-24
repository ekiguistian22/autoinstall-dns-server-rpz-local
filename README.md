<p align="center">
  <img src="https://img.shields.io/badge/Project-BIND9%20Auto%20Installer-blue?style=for-the-badge&logo=linux" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
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
chmod +x dns-setup.sh
./dns-setup.sh
```

- Masukkan subnet internal yang boleh query
- Input manual email penerima untuk alert
- Input manual Telegram Bot Token & Chat ID
- Pilih opsi instalasi

### Uninstall
```bash
./dns-setup.sh
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
