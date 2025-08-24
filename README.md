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
