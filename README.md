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
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge"/>
  <img src="https://img.shields.io/github/stars/NIGHTWALKEROFC/nw-osint-tool?style=for-the-badge&color=yellow"/>
</p>

<p align="center">
  <b>Advanced OSINT Framework for Termux — No Root Required</b><br>
  Created by <b>NIGHTWALKER</b>
</p>

---

## ⚠️ Disclaimer

This tool is intended **strictly for educational and ethical security research purposes only**.  
Only use on targets you have **explicit written permission** to investigate.  
The author **NIGHTWALKER** is not responsible for any misuse or illegal activity.  
Always comply with your local laws and regulations.

---

## 📋 Features

| # | Module | Description |
|---|--------|-------------|
| 01 | 🔍 **Username OSINT** | Search a username across 20+ platforms simultaneously |
| 02 | 🌐 **IP Address OSINT** | Full geolocation, ISP, VPN/proxy detection, map link |
| 03 | 🏠 **Domain / Website OSINT** | WHOIS, DNS records, subdomain scan, HTTP headers, robots.txt |
| 04 | 📧 **Email OSINT** | Breach check, Gravatar lookup, MX validation, social cross-check |
| 05 | 📱 **Phone Number OSINT** | Country detection, carrier info, WhatsApp/Telegram check |
| 06 | 📡 **Network OSINT** | Your IP, DNS leak test, speed test, open port scan |
| 07 | 🔎 **Google Dorking Helper** | Auto-generate dork queries with direct Google links |
| 08 | 🛠️ **Website Fingerprint** | Detect CMS, JS frameworks, CDN, SSL certificate info |
| 09 | 📂 **View Reports** | Browse and read all saved OSINT reports |

---

## 📱 Requirements

- Android device with **Termux** installed
- Internet connection
- **No root required**

---

## 🚀 Installation

### Step 1 — Install Termux

> ⚠️ Download from **F-Droid only** — the Play Store version is outdated

👉 https://f-droid.org/packages/com.termux/

---

### Step 2 — Update Termux

```bash
pkg update && pkg upgrade -y
```

---

### Step 3 — Install dependencies

```bash
pkg install git curl jq whois dnsutils wget openssl-tool python -y
```

---

### Step 4 — Clone the tool

```bash
git clone https://github.com/NIGHTWALKEROFC/nw-osint-tool.git
```

> ✅ No username or password needed — this is a public repo

---

### Step 5 — Navigate into the folder

```bash
cd nw-osint-tool
```

---

### Step 6 — Give permission

```bash
chmod +x nw_osint.sh
```

---

### Step 7 — Run the tool

```bash
bash nw_osint.sh
```

---

## ⚡ One-Line Install

Just paste this single command in Termux — it does everything automatically:

```bash
pkg update -y && pkg install git curl jq whois dnsutils wget openssl-tool python -y && git clone https://github.com/NIGHTWALKEROFC/nw-osint-tool.git && cd nw-osint-tool && chmod +x nw_osint.sh && bash nw_osint.sh
```

---

## 🔄 Update Tool

To get the latest version:

```bash
cd nw-osint-tool && git pull
```

---

## 🖥️ How to Use

After running the tool you will see a menu:

```
  [01]  Username OSINT          — Search username across 20+ platforms
  [02]  IP Address OSINT        — Geolocate & analyze any IP
  [03]  Domain / Website OSINT  — WHOIS, DNS, subdomains, headers
  [04]  Email OSINT             — Breach check, gravatar, MX lookup
  [05]  Phone Number OSINT      — Carrier, country, public links
  [06]  Network OSINT           — Your IP, DNS leak, speed, ports
  [07]  Google Dorking Helper   — Auto-generate dork queries
  [08]  Website Fingerprint     — Detect CMS, frameworks, CDN
  [09]  View Reports            — Browse saved OSINT reports
  [00]  Exit
```

Type the number and press **Enter** to select a module.

---

## 💾 Reports & Logs

All results are automatically saved. No data is sent anywhere — everything stays on your device.

View saved reports folder:
```bash
ls ~/.nw_osint/reports/
```

Read a specific report:
```bash
cat ~/.nw_osint/reports/<filename>
```

Or use **Module 09** from inside the tool to browse reports interactively.

---

## 📁 File Structure

```
nw-osint-tool/
├── nw_osint.sh        # Main tool script
├── README.md          # Documentation
├── LICENSE            # MIT License
└── .gitignore         # Git ignore rules
```

---

## 🔧 Troubleshooting

| Problem | Fix |
|---------|-----|
| Permission denied | `chmod +x nw_osint.sh` |
| `jq` not found | `pkg install jq -y` |
| `whois` not found | `pkg install whois -y` |
| `nslookup` not found | `pkg install dnsutils -y` |
| `openssl` not found | `pkg install openssl-tool -y` |
| Tool not running | `bash nw_osint.sh` |
| Clone asks for login | Make sure repo is set to **Public** on GitHub |
| Update tool | `cd nw-osint-tool && git pull` |

---

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 👤 Credits

```
  ╔══════════════════════════════════════╗
  ║          NW OSINT TOOL               ║
  ║                                      ║
  ║   Author   :  NIGHTWALKER            ║
  ║   GitHub   :  NIGHTWALKEROFC         ║
  ║   Purpose  :  Ethical OSINT          ║
  ║   Platform :  Termux (Android)       ║
  ║   Version  :  1.0                   ║
  ╚══════════════════════════════════════╝
```

> *"Knowledge is power. Use it wisely."* — NIGHTWALKER

---

## ⭐ Support

- Give this repo a **Star** ⭐ if you find it useful
- Report bugs via the **Issues** tab
- Share with the community

<p align="center">
  Made with ❤️ by <b>NIGHTWALKER</b>
</p>
