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

![PayPal QR](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAYYAAAGGAQAAAABX+xtIAAACV0lEQVR4nO2cy43bMBRFz4sEeEkBKSClSK2lpHQglZICAkjLABReFvyYM84iRuKxQ1wuvDBxABJv7vvSY8596/x0JwAiRIgQIUKECBEiHkJslhccI8BpwGm2cJat6cNPJeKhRHB39wjblwgcF0/W3yZwd3dfn3AqEQ8lzqzk+bsZhIgtwZ15J3mB55xKxAOI8eab4Nj87XP0bfox/qZ6f817iPgLYpvOouljpEbxJ59KxD8kqs4HB06Ydxz4aRB2kvnnVu6veQ8R9xOHmZmNWefbBL5ymq9AStuXJ5xKxCOInJS3K+JrTd9yQt/svuY9RNyxciEWIunDPZIsvTK4r8E9/wnI5p0QTfF9NTLzPng2fIi478X6snkHRPXtWefF3BEosm+0L5t3QBSb71C8dw7lpfE2yLd3RlSbD87sEWDIXdhcv5F8u3TeDdH6dt+HJnln3ofcZZ8Vzzsktgls4TRbDjM4Lu5fJ8iRHbDl408l4iFEE89T3l7r85zLh6vnl877INp4DiVzm92dGs+b0k0274Bo4nlS8hpKIrem3Uj2ArJ5J8SbPhw0BXnZyGWadN4N0dbnBG8HaE2/XfG8J6LReWq8rRSxrzWet4MW2bwXYt6HJpHLLyXCddpy6g1kP8S7B46NxHMzLlTFK553RoSSvKcnryFiyzE2Dj6H/Fe/h4g/WLfxPGuaWrCVqap03gdxY/Nr5319vyubd0psU52fA2w2Ystx0W8a+iGa1ksj8ZrBo/l5f8RN3l4fy5SpeZ2ky7d3Qpj+z4QIESJEiBAhQsR/R/wCJ/SRxUMdlTAAAAAASUVORK5CYII=)

---

✍️ Created with ❤️ by **Leo Ganteng**
