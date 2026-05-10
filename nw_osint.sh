#!/bin/bash

# ============================================================
#         NW OSINT TOOL - by NIGHTWALKER
#         Termux OSINT Framework | Ethical Use Only
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

TOOL_DIR="$HOME/.nw_osint"
LOG_DIR="$TOOL_DIR/logs"
REPORT_DIR="$TOOL_DIR/reports"
mkdir -p "$LOG_DIR" "$REPORT_DIR"

banner() {
    clear
    echo -e "${RED}"
    echo "  ███╗   ██╗██╗    ██╗     ██████╗ ███████╗██╗███╗   ██╗████████╗"
    echo "  ████╗  ██║██║    ██║    ██╔═══██╗██╔════╝██║████╗  ██║╚══██╔══╝"
    echo "  ██╔██╗ ██║██║ █╗ ██║    ██║   ██║███████╗██║██╔██╗ ██║   ██║   "
    echo "  ██║╚██╗██║██║███╗██║    ██║   ██║╚════██║██║██║╚██╗██║   ██║   "
    echo "  ██║ ╚████║╚███╔███╔╝    ╚██████╔╝███████║██║██║ ╚████║   ██║   "
    echo "  ╚═╝  ╚═══╝ ╚══╝╚══╝      ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝   ╚═╝  "
    echo -e "${RESET}"
    echo -e "${DIM}${WHITE}  ══════════════════════════════════════════════════════════════${RESET}"
    echo -e "${CYAN}            OSINT FRAMEWORK  |  by ${RED}NIGHTWALKER${RESET}"
    echo -e "${DIM}${WHITE}  ══════════════════════════════════════════════════════════════${RESET}"
    echo -e "${YELLOW}       [ Ethical Use Only | For Educational Purposes ]${RESET}"
    echo ""
}

log_result() {
    local module="$1"
    local query="$2"
    local result="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local logfile="$LOG_DIR/${module}_$(date '+%Y%m%d').log"
    echo "[$timestamp] Query: $query" >> "$logfile"
    echo "$result" >> "$logfile"
    echo "---" >> "$logfile"
}

check_deps() {
    local deps=("curl" "jq" "whois" "nslookup" "wget")
    local missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}[!] Missing dependencies: ${missing[*]}${RESET}"
        echo -e "${CYAN}[*] Installing...${RESET}"
        pkg install -y "${missing[@]}" 2>/dev/null
        pip install requests 2>/dev/null
    fi
}

press_enter() {
    echo ""
    echo -e "${DIM}  Press Enter to continue...${RESET}"
    read -r
}

section() {
    echo -e "\n${CYAN}  ┌─────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}  │ ${WHITE}${BOLD}$1${RESET}${CYAN}$(printf '%*s' $((41 - ${#1})) '')│${RESET}"
    echo -e "${CYAN}  └─────────────────────────────────────────┘${RESET}\n"
}

# ─────────────────────────────────────────
# MODULE 1: Username OSINT
# ─────────────────────────────────────────
username_osint() {
    banner
    section "USERNAME OSINT"
    echo -ne "${GREEN}  [?] Enter username to search: ${RESET}"
    read -r username

    if [ -z "$username" ]; then
        echo -e "${RED}  [!] No username entered.${RESET}"
        press_enter; return
    fi

    echo -e "\n${CYAN}  [*] Searching username: ${WHITE}$username${RESET}\n"

    declare -A platforms=(
        ["GitHub"]="https://github.com/$username"
        ["GitLab"]="https://gitlab.com/$username"
        ["Twitter/X"]="https://twitter.com/$username"
        ["Instagram"]="https://www.instagram.com/$username"
        ["Reddit"]="https://www.reddit.com/user/$username"
        ["TikTok"]="https://www.tiktok.com/@$username"
        ["YouTube"]="https://www.youtube.com/@$username"
        ["Pinterest"]="https://www.pinterest.com/$username"
        ["Telegram"]="https://t.me/$username"
        ["Medium"]="https://medium.com/@$username"
        ["Dev.to"]="https://dev.to/$username"
        ["Keybase"]="https://keybase.io/$username"
        ["Pastebin"]="https://pastebin.com/u/$username"
        ["HackerNews"]="https://news.ycombinator.com/user?id=$username"
        ["Steam"]="https://steamcommunity.com/id/$username"
        ["Twitch"]="https://www.twitch.tv/$username"
        ["Linktree"]="https://linktr.ee/$username"
        ["Replit"]="https://replit.com/@$username"
        ["Mastodon"]="https://mastodon.social/@$username"
        ["Snapchat"]="https://www.snapchat.com/add/$username"
    )

    local found=0
    local not_found=0
    local results=""

    for platform in "${!platforms[@]}"; do
        url="${platforms[$platform]}"
        status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 8 -L "$url" \
            -H "User-Agent: Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36")

        if [[ "$status" == "200" || "$status" == "301" || "$status" == "302" ]]; then
            echo -e "  ${GREEN}[✓] FOUND${RESET}    ${WHITE}$platform${RESET} → ${DIM}$url${RESET}"
            results+="[FOUND] $platform: $url\n"
            ((found++))
        else
            echo -e "  ${RED}[✗] NOT FOUND${RESET} ${DIM}$platform${RESET}"
            ((not_found++))
        fi
    done

    echo -e "\n${YELLOW}  ─────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}Found: $found${RESET} | ${RED}Not Found: $not_found${RESET}"

    local report="$REPORT_DIR/username_${username}_$(date '+%Y%m%d_%H%M%S').txt"
    echo -e "$results" > "$report"
    echo -e "\n${CYAN}  [✓] Report saved: ${WHITE}$report${RESET}"
    log_result "username" "$username" "$results"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 2: IP Address OSINT
# ─────────────────────────────────────────
ip_osint() {
    banner
    section "IP ADDRESS OSINT"
    echo -ne "${GREEN}  [?] Enter IP address (or press Enter for your IP): ${RESET}"
    read -r ip

    if [ -z "$ip" ]; then
        ip=$(curl -s https://api.ipify.org)
        echo -e "${CYAN}  [*] Your public IP: ${WHITE}$ip${RESET}"
    fi

    echo -e "\n${CYAN}  [*] Fetching info for: ${WHITE}$ip${RESET}\n"

    result=$(curl -s "http://ip-api.com/json/$ip?fields=status,message,country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,asname,reverse,mobile,proxy,hosting,query")

    if echo "$result" | jq -e '.status == "success"' &>/dev/null; then
        echo -e "  ${GREEN}┌─ IP INFO ────────────────────────────────┐${RESET}"
        echo -e "  ${WHITE}│ IP Address  :${RESET} $(echo $result | jq -r '.query')"
        echo -e "  ${WHITE}│ Country     :${RESET} $(echo $result | jq -r '.country') ($(echo $result | jq -r '.countryCode'))"
        echo -e "  ${WHITE}│ Region      :${RESET} $(echo $result | jq -r '.regionName')"
        echo -e "  ${WHITE}│ City        :${RESET} $(echo $result | jq -r '.city')"
        echo -e "  ${WHITE}│ ZIP         :${RESET} $(echo $result | jq -r '.zip')"
        echo -e "  ${WHITE}│ Latitude    :${RESET} $(echo $result | jq -r '.lat')"
        echo -e "  ${WHITE}│ Longitude   :${RESET} $(echo $result | jq -r '.lon')"
        echo -e "  ${WHITE}│ Timezone    :${RESET} $(echo $result | jq -r '.timezone')"
        echo -e "  ${WHITE}│ ISP         :${RESET} $(echo $result | jq -r '.isp')"
        echo -e "  ${WHITE}│ Org         :${RESET} $(echo $result | jq -r '.org')"
        echo -e "  ${WHITE}│ AS          :${RESET} $(echo $result | jq -r '.as')"
        echo -e "  ${WHITE}│ Reverse DNS :${RESET} $(echo $result | jq -r '.reverse')"
        echo -e "  ${WHITE}│ Mobile      :${RESET} $(echo $result | jq -r '.mobile')"
        echo -e "  ${WHITE}│ Proxy/VPN   :${RESET} $(echo $result | jq -r '.proxy')"
        echo -e "  ${WHITE}│ Hosting     :${RESET} $(echo $result | jq -r '.hosting')"
        echo -e "  ${GREEN}└─────────────────────────────────────────┘${RESET}"

        # Map link
        lat=$(echo $result | jq -r '.lat')
        lon=$(echo $result | jq -r '.lon')
        echo -e "\n  ${CYAN}[🗺] Map Link:${RESET} https://www.openstreetmap.org/?mlat=$lat&mlon=$lon"

        report="$REPORT_DIR/ip_${ip}_$(date '+%Y%m%d_%H%M%S').txt"
        echo "$result" | jq . > "$report"
        echo -e "\n${CYAN}  [✓] Report saved: ${WHITE}$report${RESET}"
        log_result "ip" "$ip" "$result"
    else
        echo -e "${RED}  [!] Failed to retrieve info. Check IP format.${RESET}"
    fi
    press_enter
}

# ─────────────────────────────────────────
# MODULE 3: Domain / Website OSINT
# ─────────────────────────────────────────
domain_osint() {
    banner
    section "DOMAIN / WEBSITE OSINT"
    echo -ne "${GREEN}  [?] Enter domain (e.g. example.com): ${RESET}"
    read -r domain

    if [ -z "$domain" ]; then
        echo -e "${RED}  [!] No domain entered.${RESET}"
        press_enter; return
    fi

    echo -e "\n${CYAN}  [*] Gathering info for: ${WHITE}$domain${RESET}\n"

    echo -e "${YELLOW}  ── WHOIS ───────────────────────────────────${RESET}"
    whois "$domain" 2>/dev/null | grep -iE "registrar|creation|expiry|updated|name server|status|registrant|country|email" | head -20

    echo -e "\n${YELLOW}  ── DNS RECORDS ─────────────────────────────${RESET}"
    echo -e "${WHITE}  [A Record]${RESET}"
    nslookup -type=A "$domain" 2>/dev/null | grep -v "^#\|^$\|server\|Address: 127" | head -5
    echo -e "${WHITE}  [MX Record]${RESET}"
    nslookup -type=MX "$domain" 2>/dev/null | grep "mail" | head -5
    echo -e "${WHITE}  [TXT Record]${RESET}"
    nslookup -type=TXT "$domain" 2>/dev/null | grep "text =" | head -5
    echo -e "${WHITE}  [NS Record]${RESET}"
    nslookup -type=NS "$domain" 2>/dev/null | grep "nameserver\|name server" | head -5

    echo -e "\n${YELLOW}  ── IP INFO ─────────────────────────────────${RESET}"
    domain_ip=$(nslookup "$domain" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
    if [ -n "$domain_ip" ]; then
        echo -e "  ${WHITE}Resolved IP:${RESET} $domain_ip"
        geo=$(curl -s "http://ip-api.com/json/$domain_ip?fields=country,city,isp,org,as")
        echo -e "  ${WHITE}Country:${RESET} $(echo $geo | jq -r '.country')"
        echo -e "  ${WHITE}City:${RESET} $(echo $geo | jq -r '.city')"
        echo -e "  ${WHITE}ISP:${RESET} $(echo $geo | jq -r '.isp')"
        echo -e "  ${WHITE}Org:${RESET} $(echo $geo | jq -r '.org')"
    fi

    echo -e "\n${YELLOW}  ── SUBDOMAINS (common) ─────────────────────${RESET}"
    subs=("www" "mail" "ftp" "admin" "webmail" "portal" "api" "dev" "staging" "blog" "shop" "vpn" "remote" "app")
    for sub in "${subs[@]}"; do
        result=$(nslookup "$sub.$domain" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
        if [ -n "$result" ]; then
            echo -e "  ${GREEN}[✓]${RESET} $sub.$domain → $result"
        fi
    done

    echo -e "\n${YELLOW}  ── HTTP HEADERS ────────────────────────────${RESET}"
    curl -sI "https://$domain" --max-time 8 | grep -iE "server|x-powered|content-type|strict-transport|x-frame|cf-ray|x-cache" | head -10

    echo -e "\n${YELLOW}  ── ROBOTS.TXT ──────────────────────────────${RESET}"
    curl -s "https://$domain/robots.txt" --max-time 8 | head -20

    log_result "domain" "$domain" "Domain recon completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 4: Email OSINT
# ─────────────────────────────────────────
email_osint() {
    banner
    section "EMAIL OSINT"
    echo -ne "${GREEN}  [?] Enter email address: ${RESET}"
    read -r email

    if [ -z "$email" ]; then
        echo -e "${RED}  [!] No email entered.${RESET}"
        press_enter; return
    fi

    domain=$(echo "$email" | cut -d'@' -f2)
    username=$(echo "$email" | cut -d'@' -f1)

    echo -e "\n${CYAN}  [*] Analyzing: ${WHITE}$email${RESET}\n"

    echo -e "${YELLOW}  ── EMAIL BREAKDOWN ─────────────────────────${RESET}"
    echo -e "  ${WHITE}Username:${RESET} $username"
    echo -e "  ${WHITE}Domain:${RESET}   $domain"

    echo -e "\n${YELLOW}  ── MX RECORD CHECK ─────────────────────────${RESET}"
    mx=$(nslookup -type=MX "$domain" 2>/dev/null | grep "mail" | head -3)
    if [ -n "$mx" ]; then
        echo -e "  ${GREEN}[✓] MX records found (domain is valid for email)${RESET}"
        echo "$mx"
    else
        echo -e "  ${RED}[✗] No MX records found${RESET}"
    fi

    echo -e "\n${YELLOW}  ── BREACH CHECK (HaveIBeenPwned) ───────────${RESET}"
    breach=$(curl -s "https://haveibeenpwned.com/api/v3/breachedaccount/$email" \
        -H "hibp-api-key: public" \
        -H "User-Agent: NW-OSINT-Tool" 2>/dev/null)
    if echo "$breach" | grep -q "breachDate\|Name"; then
        echo -e "  ${RED}[!] Email found in breaches!${RESET}"
        echo "$breach" | grep -o '"Name":"[^"]*"' | head -10
    else
        echo -e "  ${GREEN}[✓] Not found in public breach databases (or API key needed)${RESET}"
        echo -e "  ${DIM}  Tip: Visit https://haveibeenpwned.com manually for full check${RESET}"
    fi

    echo -e "\n${YELLOW}  ── GRAVATAR CHECK ──────────────────────────${RESET}"
    md5hash=$(echo -n "$email" | md5sum | cut -d' ' -f1)
    gravatar_url="https://www.gravatar.com/avatar/$md5hash?d=404"
    gravatar_status=$(curl -o /dev/null -s -w "%{http_code}" "$gravatar_url" --max-time 8)
    if [ "$gravatar_status" == "200" ]; then
        echo -e "  ${GREEN}[✓] Gravatar profile found!${RESET}"
        echo -e "  ${WHITE}Avatar:${RESET} https://www.gravatar.com/avatar/$md5hash"
        echo -e "  ${WHITE}Profile:${RESET} https://www.gravatar.com/$md5hash"
    else
        echo -e "  ${RED}[✗] No Gravatar profile${RESET}"
    fi

    echo -e "\n${YELLOW}  ── POSSIBLE SOCIAL PROFILES ────────────────${RESET}"
    echo -e "  ${CYAN}Checking username '$username' on platforms...${RESET}"
    platforms=("github.com" "twitter.com" "instagram.com" "reddit.com")
    for p in "${platforms[@]}"; do
        url="https://$p/$username"
        status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 6 -L "$url" \
            -H "User-Agent: Mozilla/5.0")
        if [[ "$status" == "200" ]]; then
            echo -e "  ${GREEN}[✓]${RESET} $url"
        fi
    done

    log_result "email" "$email" "Email OSINT completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 5: Phone Number OSINT
# ─────────────────────────────────────────
phone_osint() {
    banner
    section "PHONE NUMBER OSINT"
    echo -ne "${GREEN}  [?] Enter phone number (with country code, e.g. +919876543210): ${RESET}"
    read -r phone

    if [ -z "$phone" ]; then
        echo -e "${RED}  [!] No number entered.${RESET}"
        press_enter; return
    fi

    echo -e "\n${CYAN}  [*] Analyzing: ${WHITE}$phone${RESET}\n"

    echo -e "${YELLOW}  ── NUMBER ANALYSIS ─────────────────────────${RESET}"

    # Basic parsing
    country_code=""
    if [[ "$phone" == +91* ]]; then
        country_code="India 🇮🇳"
    elif [[ "$phone" == +1* ]]; then
        country_code="USA/Canada 🇺🇸"
    elif [[ "$phone" == +44* ]]; then
        country_code="United Kingdom 🇬🇧"
    elif [[ "$phone" == +61* ]]; then
        country_code="Australia 🇦🇺"
    elif [[ "$phone" == +971* ]]; then
        country_code="UAE 🇦🇪"
    elif [[ "$phone" == +92* ]]; then
        country_code="Pakistan 🇵🇰"
    elif [[ "$phone" == +880* ]]; then
        country_code="Bangladesh 🇧🇩"
    else
        country_code="Unknown"
    fi

    echo -e "  ${WHITE}Number:${RESET}       $phone"
    echo -e "  ${WHITE}Country:${RESET}      $country_code"
    echo -e "  ${WHITE}Digits:${RESET}       ${#phone}"

    echo -e "\n${YELLOW}  ── PUBLIC LOOKUP LINKS ─────────────────────${RESET}"
    clean_phone=$(echo "$phone" | tr -d '+- ')
    echo -e "  ${WHITE}Truecaller:${RESET}    https://www.truecaller.com/search/in/$clean_phone"
    echo -e "  ${WHITE}Sync.me:${RESET}       https://sync.me/search/?number=$phone"
    echo -e "  ${WHITE}SpamCalls:${RESET}     https://www.shouldianswer.com/phone-number/$clean_phone"

    echo -e "\n${YELLOW}  ── WHATSAPP CHECK ──────────────────────────${RESET}"
    echo -e "  ${DIM}  wa.me link (opens if registered):${RESET}"
    wa_number=$(echo "$phone" | tr -d '+')
    echo -e "  ${WHITE}https://wa.me/$wa_number${RESET}"

    echo -e "\n${YELLOW}  ── TELEGRAM CHECK ──────────────────────────${RESET}"
    echo -e "  ${DIM}  Check if registered on Telegram:${RESET}"
    echo -e "  ${WHITE}https://t.me/+$wa_number${RESET}"

    log_result "phone" "$phone" "Phone OSINT completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 6: Network OSINT
# ─────────────────────────────────────────
network_osint() {
    banner
    section "NETWORK OSINT"
    echo -e "${CYAN}  [*] Gathering your network information...\n${RESET}"

    echo -e "${YELLOW}  ── YOUR PUBLIC IP ──────────────────────────${RESET}"
    pub_ip=$(curl -s https://api.ipify.org)
    echo -e "  ${WHITE}Public IP:${RESET} $pub_ip"

    echo -e "\n${YELLOW}  ── IP GEOLOCATION ──────────────────────────${RESET}"
    geo=$(curl -s "http://ip-api.com/json/$pub_ip")
    echo -e "  ${WHITE}Country:${RESET}  $(echo $geo | jq -r '.country')"
    echo -e "  ${WHITE}City:${RESET}     $(echo $geo | jq -r '.city')"
    echo -e "  ${WHITE}ISP:${RESET}      $(echo $geo | jq -r '.isp')"
    echo -e "  ${WHITE}Org:${RESET}      $(echo $geo | jq -r '.org')"
    echo -e "  ${WHITE}AS:${RESET}       $(echo $geo | jq -r '.as')"
    echo -e "  ${WHITE}Timezone:${RESET} $(echo $geo | jq -r '.timezone')"
    echo -e "  ${WHITE}VPN/Proxy:${RESET} $(echo $geo | jq -r '.proxy')"

    echo -e "\n${YELLOW}  ── DNS LEAK TEST ───────────────────────────${RESET}"
    dns_ip=$(nslookup myip.opendns.com resolver1.opendns.com 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}')
    echo -e "  ${WHITE}DNS-resolved IP:${RESET} $dns_ip"
    if [ "$pub_ip" == "$dns_ip" ]; then
        echo -e "  ${GREEN}[✓] No DNS leak detected${RESET}"
    else
        echo -e "  ${YELLOW}[!] Possible DNS leak — IPs differ${RESET}"
    fi

    echo -e "\n${YELLOW}  ── SPEED TEST (quick) ──────────────────────${RESET}"
    echo -e "  ${CYAN}Testing download speed...${RESET}"
    speed=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 10 \
        "http://speedtest.ftp.otenet.gr/files/test1Mb.db")
    speed_kbps=$(echo "$speed / 1024" | bc)
    speed_mbps=$(echo "scale=2; $speed / 1048576" | bc)
    echo -e "  ${WHITE}Download Speed:${RESET} ~${speed_mbps} Mbps (${speed_kbps} KB/s)"

    echo -e "\n${YELLOW}  ── OPEN PORTS ON LOCALHOST ─────────────────${RESET}"
    echo -e "  ${CYAN}Scanning common ports on localhost...${RESET}"
    for port in 21 22 23 25 53 80 443 3306 5432 8080 8888; do
        if timeout 1 bash -c "echo >/dev/tcp/127.0.0.1/$port" 2>/dev/null; then
            echo -e "  ${GREEN}[OPEN]${RESET}  Port $port"
        fi
    done

    press_enter
}

# ─────────────────────────────────────────
# MODULE 7: Google Dorking Helper
# ─────────────────────────────────────────
google_dork() {
    banner
    section "GOOGLE DORKING HELPER"
    echo -e "${DIM}  Generates Google dork queries for OSINT research${RESET}\n"
    echo -ne "${GREEN}  [?] Enter target (domain, name, or keyword): ${RESET}"
    read -r target

    if [ -z "$target" ]; then
        press_enter; return
    fi

    echo -e "\n${YELLOW}  ── GENERATED DORK QUERIES ──────────────────${RESET}\n"

    dorks=(
        "site:$target"
        "inurl:$target"
        "intitle:\"$target\""
        "\"$target\" filetype:pdf"
        "\"$target\" filetype:doc OR filetype:docx"
        "\"$target\" filetype:xls OR filetype:xlsx"
        "site:$target inurl:admin"
        "site:$target inurl:login"
        "site:$target inurl:config"
        "site:$target ext:sql OR ext:db"
        "site:$target ext:log"
        "site:linkedin.com \"$target\""
        "site:pastebin.com \"$target\""
        "site:github.com \"$target\""
        "\"@$target\" email"
        "\"$target\" password"
        "cache:$target"
    )

    for dork in "${dorks[@]}"; do
        encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$dork'))" 2>/dev/null)
        echo -e "  ${GREEN}►${RESET} ${WHITE}$dork${RESET}"
        echo -e "    ${DIM}https://www.google.com/search?q=$encoded${RESET}\n"
    done

    report="$REPORT_DIR/dorks_${target}_$(date '+%Y%m%d_%H%M%S').txt"
    for dork in "${dorks[@]}"; do
        echo "$dork" >> "$report"
    done
    echo -e "${CYAN}  [✓] Dorks saved: ${WHITE}$report${RESET}"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 8: Website Tech Fingerprint
# ─────────────────────────────────────────
tech_fingerprint() {
    banner
    section "WEBSITE TECH FINGERPRINT"
    echo -ne "${GREEN}  [?] Enter website URL (e.g. https://example.com): ${RESET}"
    read -r url

    if [ -z "$url" ]; then
        press_enter; return
    fi

    echo -e "\n${CYAN}  [*] Fingerprinting: ${WHITE}$url${RESET}\n"

    echo -e "${YELLOW}  ── HTTP HEADERS ────────────────────────────${RESET}"
    headers=$(curl -sI "$url" --max-time 10 -L)
    echo "$headers" | grep -iE "server|x-powered|x-generator|cf-ray|x-cache|x-drupal|x-wordpress|via|set-cookie|content-type|strict-transport|access-control"

    echo -e "\n${YELLOW}  ── TECHNOLOGY DETECTION ────────────────────${RESET}"
    body=$(curl -sL "$url" --max-time 10 -A "Mozilla/5.0")

    # CMS detection
    if echo "$body" | grep -qi "wp-content\|wordpress"; then
        echo -e "  ${GREEN}[✓] CMS: WordPress detected${RESET}"
    fi
    if echo "$body" | grep -qi "Drupal"; then
        echo -e "  ${GREEN}[✓] CMS: Drupal detected${RESET}"
    fi
    if echo "$body" | grep -qi "Joomla"; then
        echo -e "  ${GREEN}[✓] CMS: Joomla detected${RESET}"
    fi
    if echo "$body" | grep -qi "shopify"; then
        echo -e "  ${GREEN}[✓] Platform: Shopify detected${RESET}"
    fi
    if echo "$body" | grep -qi "wix.com"; then
        echo -e "  ${GREEN}[✓] Platform: Wix detected${RESET}"
    fi

    # JS frameworks
    if echo "$body" | grep -qi "react\|_react\|__react"; then
        echo -e "  ${GREEN}[✓] JS Framework: React detected${RESET}"
    fi
    if echo "$body" | grep -qi "vue\.js\|vuejs"; then
        echo -e "  ${GREEN}[✓] JS Framework: Vue.js detected${RESET}"
    fi
    if echo "$body" | grep -qi "angular"; then
        echo -e "  ${GREEN}[✓] JS Framework: Angular detected${RESET}"
    fi
    if echo "$body" | grep -qi "jquery"; then
        echo -e "  ${GREEN}[✓] JS Library: jQuery detected${RESET}"
    fi

    # Analytics
    if echo "$body" | grep -qi "google-analytics\|gtag\|UA-"; then
        echo -e "  ${GREEN}[✓] Analytics: Google Analytics detected${RESET}"
    fi
    if echo "$body" | grep -qi "fbq\|facebook pixel"; then
        echo -e "  ${GREEN}[✓] Analytics: Facebook Pixel detected${RESET}"
    fi

    # CDN
    if echo "$headers" | grep -qi "cloudflare\|cf-ray"; then
        echo -e "  ${GREEN}[✓] CDN: Cloudflare detected${RESET}"
    fi
    if echo "$headers" | grep -qi "fastly"; then
        echo -e "  ${GREEN}[✓] CDN: Fastly detected${RESET}"
    fi

    echo -e "\n${YELLOW}  ── SSL CERTIFICATE ─────────────────────────${RESET}"
    domain=$(echo "$url" | sed 's|https://||;s|http://||;s|/.*||')
    echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | \
        openssl x509 -noout -dates -issuer -subject 2>/dev/null | head -10

    press_enter
}

# ─────────────────────────────────────────
# MODULE 9: View Reports
# ─────────────────────────────────────────
view_reports() {
    banner
    section "SAVED REPORTS"
    files=("$REPORT_DIR"/*)
    if [ ${#files[@]} -eq 0 ] || [ ! -e "${files[0]}" ]; then
        echo -e "  ${YELLOW}[!] No reports found yet.${RESET}"
        press_enter; return
    fi

    echo -e "  ${WHITE}Reports saved in: ${CYAN}$REPORT_DIR${RESET}\n"
    i=1
    for f in "$REPORT_DIR"/*; do
        fname=$(basename "$f")
        fsize=$(wc -c < "$f")
        echo -e "  ${GREEN}[$i]${RESET} $fname ${DIM}(${fsize} bytes)${RESET}"
        ((i++))
    done

    echo -e "\n${GREEN}  [?] Enter report number to view (or 0 to go back): ${RESET}"
    read -r choice

    if [[ "$choice" -gt 0 && "$choice" -lt "$i" ]]; then
        selected=$(ls "$REPORT_DIR" | sed -n "${choice}p")
        echo -e "\n${CYAN}  ── $selected ───────────────────────────────${RESET}\n"
        cat "$REPORT_DIR/$selected"
    fi
    press_enter
}

# ─────────────────────────────────────────
# MAIN MENU
# ─────────────────────────────────────────
main_menu() {
    while true; do
        banner
        echo -e "  ${WHITE}${BOLD}MODULES${RESET}\n"
        echo -e "  ${RED}[01]${RESET} ${WHITE}Username OSINT${RESET}          ${DIM}— Search username across 20+ platforms${RESET}"
        echo -e "  ${RED}[02]${RESET} ${WHITE}IP Address OSINT${RESET}         ${DIM}— Geolocate & analyze any IP${RESET}"
        echo -e "  ${RED}[03]${RESET} ${WHITE}Domain / Website OSINT${RESET}   ${DIM}— WHOIS, DNS, subdomains, headers${RESET}"
        echo -e "  ${RED}[04]${RESET} ${WHITE}Email OSINT${RESET}              ${DIM}— Breach check, gravatar, MX lookup${RESET}"
        echo -e "  ${RED}[05]${RESET} ${WHITE}Phone Number OSINT${RESET}       ${DIM}— Carrier, country, public links${RESET}"
        echo -e "  ${RED}[06]${RESET} ${WHITE}Network OSINT${RESET}            ${DIM}— Your IP, DNS leak, speed, ports${RESET}"
        echo -e "  ${RED}[07]${RESET} ${WHITE}Google Dorking Helper${RESET}    ${DIM}— Auto-generate dork queries${RESET}"
        echo -e "  ${RED}[08]${RESET} ${WHITE}Website Fingerprint${RESET}      ${DIM}— Detect CMS, frameworks, CDN${RESET}"
        echo -e "  ${RED}[09]${RESET} ${WHITE}View Reports${RESET}             ${DIM}— Browse saved OSINT reports${RESET}"
        echo -e "  ${RED}[00]${RESET} ${WHITE}Exit${RESET}"
        echo ""
        echo -e "  ${DIM}─────────────────────────────────────────────────${RESET}"
        echo -ne "  ${GREEN}NIGHTWALKER@nw-osint${RESET}${CYAN}:~# ${RESET}"
        read -r choice

        case "$choice" in
            01|1) username_osint ;;
            02|2) ip_osint ;;
            03|3) domain_osint ;;
            04|4) email_osint ;;
            05|5) phone_osint ;;
            06|6) network_osint ;;
            07|7) google_dork ;;
            08|8) tech_fingerprint ;;
            09|9) view_reports ;;
            00|0|exit|quit) 
                banner
                echo -e "  ${RED}Goodbye, NIGHTWALKER. Stay ethical.${RESET}\n"
                exit 0 ;;
            *) echo -e "  ${RED}[!] Invalid option.${RESET}"; sleep 1 ;;
        esac
    done
}

# ─────────────────────────────────────────
# STARTUP
# ─────────────────────────────────────────
banner
echo -e "  ${CYAN}[*] Checking dependencies...${RESET}"
check_deps
echo -e "  ${GREEN}[✓] All systems ready.${RESET}"
sleep 1
main_menu
