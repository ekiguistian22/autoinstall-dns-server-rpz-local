# 🚀 DNS Server Installer with BIND9  
*Created by **Leo Ganteng***  

```ascii
██████╗ ███╗   ██╗███████╗    ██████╗  █████╗ ███╗   ██╗████████╗███████╗███╗   ██╗ ██████╗
██╔══██╗████╗  ██║██╔════╝    ██╔══██╗██╔══██╗████╗  ██║╚══██╔══╝██╔════╝████╗  ██║██╔════╝
██████╔╝██╔██╗ ██║█████╗      ██████╔╝███████║██╔██╗ ██║   ██║   █████╗  ██╔██╗ ██║██║  ███╗
██╔═══╝ ██║╚██╗██║██╔══╝      ██╔═══╝ ██╔══██║██║╚██╗██║   ██║   ██╔══╝  ██║╚██╗██║██║   ██║
██║     ██║ ╚████║███████╗    ██║     ██║  ██║██║ ╚████║   ██║   ███████╗██║ ╚████║╚██████╔╝
╚═╝     ╚═╝  ╚═══╝╚══════╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝ ╚═════╝
✨ Features

🔒 Secure Caching DNS Server with BIND9

📜 RPZ Blocklist (StevenBlack hosts auto-converted)

✅ Whitelist domains

📡 Auto-update Blocklist from external source

📊 Logging & Security Monitoring

📧 Email Alerts via SMTP

📲 Telegram Alerts

💾 Auto-backup daily (/root/dns-backup/)

🔄 Watchdog auto-restart if service down

⚡ Installation
chmod +x installer.sh
./installer.sh

🛠️ Usage

Pilih Install / Konfigurasi → otomatis setup BIND9, blocklist, whitelist, logging, alerts.

Pilih Uninstall → hapus semua konfigurasi + backup otomatis.

📦 Auto Backup

Setiap hari pukul 00:30 → backup ke:

/root/dns-backup/dns-backup-YYYYMMDD.tar.gz

📢 Alerts

Email: via SMTP (input manual saat instalasi).

Telegram: kirim ke chat/group (input manual Bot Token & Chat ID saat instalasi).

🛡️ Blocklist & Whitelist

Blocklist otomatis download & convert dari StevenBlack/hosts ke RPZ format.

Whitelist bisa ditambah manual di:

/etc/bind/whitelist.db

💖 Support Me

Jika script ini bermanfaat, boleh traktir kopi/jajan via PayPal 😎👇

📧 Email PayPal: ekiguistian@gmail.com

👨‍💻 Author

Leo Ganteng

🌍 Indonesia

📡 SysAdmin / DevOps / Network Enthusiast

🔥 Keep the DNS secure & fast!
