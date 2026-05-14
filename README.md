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

| # | Module | Description |
|---|--------|-------------|
| 01 | 🔍 **Username OSINT** | Search a username across 30+ platforms simultaneously with parallel scanning and progress bar |
| 02 | 🌐 **IP Address OSINT** | Full geolocation, ISP, ASN info, VPN/proxy detection, AbuseIPDB reputation score |
| 03 | 🏠 **Domain / Website OSINT** | WHOIS, DNS records, SSL expiry countdown, HTTP redirect check, subdomain scan, headers, robots.txt |
| 04 | 📧 **Email OSINT** | Breach check, Gravatar lookup, MX validation, social profile cross-check |
| 05 | 📱 **Phone Number OSINT** | 60+ country detection, E.164 format, carrier links, WhatsApp and Telegram check |
| 06 | 📡 **Network OSINT** | Public IP, geolocation, DNS leak test, speed test, open local port scan |
| 07 | 🔎 **Google Dorking** | Auto-generate 19 targeted dork queries with direct Google links |
| 08 | 🛠️ **Website Fingerprint** | Detect CMS, JS frameworks, CDN, analytics tools, SSL certificate info |
| 09 | 🕰️ **Wayback Machine** | Check archived snapshots, history links, total crawl count via CDX API |
| 10 | 🐙 **GitHub OSINT** | Profile info, repos, organizations, gists, follower stats via GitHub API |
| 11 | 👁️ **Shodan Lookup** | Exposed ports, hostnames, CVEs, service banners — API key saved locally |
| 12 | 💥 **DNS Brute Force** | 100+ subdomain wordlist scan with parallel resolution and progress bar |
| 13 | 🔑 **Hash Identifier** | Identify MD5/SHA/bcrypt/crypt hash types, online lookup, generate hashes for comparison |
| 14 | 📶 **MAC Address Lookup** | Vendor and manufacturer from MAC address, multicast/locally-administered detection |
| 15 | 🔗 **URL Expander** | Unshorten URLs, trace full redirect chain, suspicious TLD warning, VirusTotal link |
| 16 | 📡 **Banner Grabber** | Grab service banners from open ports using native bash TCP — no netcat needed |
| 17 | 📜 **Search History** | Browse and keyword-search all past queries, clear history |
| 18 | 📂 **View Reports** | Browse and read all saved OSINT reports |
| 19 | 📦 **Export Reports to ZIP** | Bundle all saved reports into a single zip file |
| 20 | 🔐 **API Key Manager** | Add, update, or delete Shodan and AbuseIPDB API keys |

---

## Install

Get Termux from F-Droid (not Play Store) → https://f-droid.org/packages/com.termux/

```bash
pkg update && pkg upgrade -y
```

```bash
pkg install git curl jq whois dnsutils wget openssl-tool python zip -y
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
pkg update -y && pkg install git curl jq whois dnsutils wget openssl-tool python zip -y && git clone https://github.com/NIGHTWALKEROFC/nw-osint-tool.git && cd nw-osint-tool && chmod +x nw_osint.sh && bash nw_osint.sh
```

---

## Update

```bash
cd nw-osint-tool && git pull
```

---

## API Keys

Some modules work better with free API keys. The tool will prompt you when needed, verify the key, and save it locally — never shared or uploaded anywhere.

| Service | Module | Get Free Key |
|---------|--------|-------------|
| Shodan | Module 11 | https://account.shodan.io/register |
| AbuseIPDB | Module 02 | https://www.abuseipdb.com/register |

Keys are managed from **Module 20 — API Key Manager**.

---

## Reports

Everything gets saved locally on your device under `~/.nw_osint/reports/` — nothing sent anywhere. Browse them from Module 18 or read directly:

```bash
ls ~/.nw_osint/reports/
```

Export all reports as a zip from Module 19, or run:

```bash
zip -j ~/reports.zip ~/.nw_osint/reports/*
```

---

## Credits

```
  ╔══════════════════════════════════════╗
  ║          NW OSINT TOOL               ║
  ║                                      ║
  ║   Author   :  NIGHTWALKER            ║
  ║   GitHub   :  NIGHTWALKEROFC         ║
  ║   Purpose  :  Ethical OSINT          ║
  ║   Platform :  Termux (Android)       ║
  ╚══════════════════════════════════════╝
```

> *"Knowledge is power. Use it wisely."* — NIGHTWALKER

---

<p align="center">⭐ Drop a star if you find this useful</p>
