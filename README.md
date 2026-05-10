# NW OSINT Tool

```
  ███╗   ██╗██╗    ██╗     ██████╗ ███████╗██╗███╗   ██╗████████╗
  ████╗  ██║██║    ██║    ██╔═══██╗██╔════╝██║████╗  ██║╚══██╔══╝
  ██╔██╗ ██║██║ █╗ ██║    ██║   ██║███████╗██║██╔██╗ ██║   ██║   
  ██║╚██╗██║██║███╗██║    ██║   ██║╚════██║██║██║╚██╗██║   ██║   
  ██║ ╚████║╚███╔███╔╝    ╚██████╔╝███████║██║██║ ╚████║   ██║   
  ╚═╝  ╚═══╝ ╚══╝╚══╝      ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝   ╚═╝  
```

> **OSINT Framework for Termux | Ethical Use Only**  
> Created by **NIGHTWALKER**

---

## ⚠️ Disclaimer

This tool is intended for **educational and ethical security research purposes only**.  
Only use on systems and targets you have **explicit permission** to investigate.  
The author is not responsible for any misuse or damage caused by this tool.  
Always follow your local laws and regulations.

---

## 📋 Features

| Module | Description |
|--------|-------------|
| 🔍 **Username OSINT** | Search a username across 20+ platforms simultaneously |
| 🌐 **IP Address OSINT** | Full geolocation, ISP, VPN/proxy detection, map link |
| 🏠 **Domain / Website OSINT** | WHOIS, DNS records, subdomain scan, HTTP headers |
| 📧 **Email OSINT** | Breach check, Gravatar lookup, MX validation |
| 📱 **Phone Number OSINT** | Country detection, carrier info, public lookup links |
| 📡 **Network OSINT** | Your IP, DNS leak test, speed test, open port scan |
| 🔎 **Google Dorking Helper** | Auto-generate dork queries with direct Google links |
| 🛠️ **Website Fingerprint** | Detect CMS, JS frameworks, CDN, SSL certificate |
| 📂 **View Reports** | Browse and read all saved OSINT reports |

---

## 📱 Requirements

- **Android** device with **Termux** installed
- Internet connection
- No root required

### Dependencies (auto-installed)
- `curl`
- `jq`
- `whois`
- `dnsutils` (nslookup)
- `wget`
- `openssl`

---

## 🚀 Installation

### Step 1 — Install Termux
Download Termux from **F-Droid** (recommended, not Play Store):  
👉 https://f-droid.org/packages/com.termux/

### Step 2 — Update Termux packages
```bash
pkg update && pkg upgrade -y
```

### Step 3 — Install dependencies
```bash
pkg install curl jq whois dnsutils wget openssl-tool python -y
```

### Step 4 — Clone this repository
```bash
git clone https://github.com/NIGHTWALKER/nw-osint-tool
```

### Step 5 — Navigate to the directory
```bash
cd nw-osint-tool
```

### Step 6 — Give execute permission
```bash
chmod +x nw_osint.sh
```

### Step 7 — Run the tool
```bash
bash nw_osint.sh
```

---

## ⚡ Quick Install (One-liner)

```bash
pkg update -y && pkg install curl jq whois dnsutils wget openssl-tool python git -y && git clone https://github.com/NIGHTWALKER/nw-osint-tool && cd nw-osint-tool && chmod +x nw_osint.sh && bash nw_osint.sh
```

---

## 📁 File Structure

```
nw-osint-tool/
├── nw_osint.sh          # Main tool script
├── README.md            # Documentation
├── LICENSE              # MIT License
└── screenshots/         # Tool screenshots
```

---

## 💾 Reports

All OSINT results are automatically saved to:
```
~/.nw_osint/reports/
```

Logs are saved to:
```
~/.nw_osint/logs/
```

To view saved reports from inside the tool, use **Module 09**.

To view from terminal directly:
```bash
ls ~/.nw_osint/reports/
```
```bash
cat ~/.nw_osint/reports/<filename>
```

---

## 🖥️ Usage

```
NIGHTWALKER@nw-osint:~# 01   → Username OSINT
NIGHTWALKER@nw-osint:~# 02   → IP Address OSINT
NIGHTWALKER@nw-osint:~# 03   → Domain OSINT
NIGHTWALKER@nw-osint:~# 04   → Email OSINT
NIGHTWALKER@nw-osint:~# 05   → Phone Number OSINT
NIGHTWALKER@nw-osint:~# 06   → Network OSINT
NIGHTWALKER@nw-osint:~# 07   → Google Dorking Helper
NIGHTWALKER@nw-osint:~# 08   → Website Fingerprint
NIGHTWALKER@nw-osint:~# 09   → View Reports
NIGHTWALKER@nw-osint:~# 00   → Exit
```

---

## 🔧 Troubleshooting

**Tool not running?**
```bash
bash nw_osint.sh
```

**Permission denied?**
```bash
chmod +x nw_osint.sh
```

**jq not found?**
```bash
pkg install jq -y
```

**whois not found?**
```bash
pkg install whois -y
```

**nslookup not found?**
```bash
pkg install dnsutils -y
```

**openssl not found?**
```bash
pkg install openssl-tool -y
```

**Update the tool:**
```bash
cd nw-osint-tool && git pull
```

---

## 📜 License

MIT License — see [LICENSE](LICENSE) file for details.

---

## 👤 Credits

```
  Tool Name  :  NW OSINT Tool
  Author     :  NIGHTWALKER
  Purpose    :  Ethical OSINT & Security Research
  Platform   :  Termux (Android)
  Version    :  1.0
```

> *"Knowledge is power. Use it wisely."* — NIGHTWALKER

---

## ⭐ Support

If you find this tool useful, give it a **star** on GitHub!  
Report issues via the **Issues** tab.
