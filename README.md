# NW OSINT Tool

```
  ███╗   ██╗██╗    ██╗     ██████╗ ███████╗██╗███╗   ██╗████████╗
  ████╗  ██║██║    ██║    ██╔═══██╗██╔════╝██║████╗  ██║╚══██╔══╝
  ██╔██╗ ██║██║ █╗ ██║    ██║   ██║███████╗██║██╔██╗ ██║   ██║   
  ██║╚██╗██║██║███╗██║    ██║   ██║╚════██║██║██║╚██╗██║   ██║   
  ██║ ╚████║╚███╔███╔╝    ╚██████╔╝███████║██║██║ ╚████║   ██║   
  ╚═╝  ╚═══╝ ╚══╝╚══╝      ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝   ╚═╝  
```

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Termux-black?style=for-the-badge&logo=android&logoColor=green"/>
  <img src="https://img.shields.io/badge/Language-Bash-red?style=for-the-badge&logo=gnubash&logoColor=white"/>
  <img src="https://img.shields.io/badge/Root-Not%20Required-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Author-NIGHTWALKER-red?style=for-the-badge"/>
  <img src="https://img.shields.io/github/stars/NIGHTWALKEROFC/nw-osint-tool?style=for-the-badge&color=yellow"/>
</p>

<p align="center">Advanced OSINT Framework built for Termux — No root needed<br>
by <b>NIGHTWALKER</b></p>

---

> ⚠️ For educational and ethical use only. Use on targets you have permission to investigate. Author is not responsible for any misuse.

---

## What it does

| Module | Description |
|--------|-------------|
| 🔍 Username OSINT | Hunt a username across 20+ platforms |
| 🌐 IP Address OSINT | Geolocate, ISP, proxy/VPN detection |
| 🏠 Domain OSINT | WHOIS, DNS, subdomains, headers, robots.txt |
| 📧 Email OSINT | Breach check, Gravatar, MX lookup |
| 📱 Phone OSINT | Country, carrier, WhatsApp/Telegram check |
| 📡 Network OSINT | Your IP, DNS leak test, speed, open ports |
| 🔎 Google Dorking | Auto-generate dork queries |
| 🛠️ Web Fingerprint | CMS, frameworks, CDN, SSL info |
| 📂 View Reports | Browse all saved results |

---

## Install

Get Termux from F-Droid (not Play Store) → https://f-droid.org/packages/com.termux/

```bash
pkg update && pkg upgrade -y
```

```bash
pkg install git curl jq whois dnsutils wget openssl-tool python -y
```

```bash
git clone https://github.com/NIGHTWALKEROFC/nw-osint-tool.git
```

```bash
cd nw-osint-tool
```

```bash
chmod +x nw_osint.sh && bash nw_osint.sh
```

---

## One liner

```bash
pkg update -y && pkg install git curl jq whois dnsutils wget openssl-tool python -y && git clone https://github.com/NIGHTWALKEROFC/nw-osint-tool.git && cd nw-osint-tool && chmod +x nw_osint.sh && bash nw_osint.sh
```

---

## Update

```bash
cd nw-osint-tool && git pull
```

---

## Reports

Everything gets saved locally on your device under `~/.nw_osint/reports/` — nothing is sent anywhere. You can browse them from Module 09 inside the tool or read them directly:

```bash
ls ~/.nw_osint/reports/
```

---

## Credits

```
  ╔══════════════════════════════════════╗
  ║          NW OSINT TOOL               ║
  ║                                      ║
  ║   Author   :  NIGHTWALKER            ║
  ║   GitHub   :  NIGHTWALKEROFC         ║
  ║   Platform :  Termux (Android)       ║
  ║   Version  :  1.0                   ║
  ╚══════════════════════════════════════╝
```

> *"Knowledge is power. Use it wisely."* — NIGHTWALKER

---

<p align="center">⭐ Drop a star if you find this useful</p>
