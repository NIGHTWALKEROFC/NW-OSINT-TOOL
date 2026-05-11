#!/bin/bash

# ============================================================
#         NW OSINT TOOL - by NIGHTWALKER
#         Termux OSINT Framework | Ethical Use Only
#         Version: 1.1
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

TOOL_DIR="$HOME/.nw_osint"
LOG_DIR="$TOOL_DIR/logs"
REPORT_DIR="$TOOL_DIR/reports"
CONFIG_FILE="$TOOL_DIR/config"
mkdir -p "$LOG_DIR" "$REPORT_DIR"

# ─────────────────────────────────────────
# BANNER
# ─────────────────────────────────────────
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
    echo -e "${YELLOW}         [ Ethical Use Only | For Educational Purposes ]${RESET}"
    echo ""
}

# ─────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────
press_enter() {
    echo ""
    echo -e "${DIM}  Press Enter to continue...${RESET}"
    read -r
}

section() {
    echo -e "\n${CYAN}  ┌─────────────────────────────────────────┐${RESET}"
    printf "${CYAN}  │ ${WHITE}${BOLD}%-41s${RESET}${CYAN}│${RESET}\n" "$1"
    echo -e "${CYAN}  └─────────────────────────────────────────┘${RESET}\n"
}

log_result() {
    local module="$1"
    local query="$2"
    local result="$3"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local logfile="$LOG_DIR/${module}_$(date '+%Y%m%d').log"
    {
        echo "[$timestamp] Query: $query"
        echo "$result"
        echo "---"
    } >> "$logfile"
}

save_report() {
    local name="$1"
    local content="$2"
    local report="$REPORT_DIR/${name}_$(date '+%Y%m%d_%H%M%S').txt"
    printf "%b" "$content" > "$report"
    echo -e "\n${CYAN}  [✓] Report saved: ${WHITE}$report${RESET}"
}

# FIX: pure python3 md5 — md5sum not reliable on all Termux builds
make_md5() {
    python3 -c "import hashlib,sys; print(hashlib.md5(sys.argv[1].encode()).hexdigest())" "$1" 2>/dev/null
}

# ─────────────────────────────────────────
# DEPENDENCY CHECK
# ─────────────────────────────────────────
check_deps() {
    local missing=()
    for dep in curl jq whois nslookup wget openssl python3; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}  [!] Missing: ${missing[*]}${RESET}"
        echo -e "${CYAN}  [*] Installing dependencies...${RESET}"
        pkg install -y curl jq whois dnsutils wget openssl-tool python 2>/dev/null
        echo -e "${GREEN}  [✓] Done.${RESET}"
    fi
}

# ─────────────────────────────────────────
# UPDATE CHECKER
# ─────────────────────────────────────────
check_update() {
    local current_version="1.1"
    local remote_version
    remote_version=$(curl -s --max-time 5 \
        "https://raw.githubusercontent.com/NIGHTWALKEROFC/nw-osint-tool/main/version.txt" 2>/dev/null | tr -d '[:space:]')
    if [ -n "$remote_version" ] && [ "$remote_version" != "$current_version" ]; then
        echo -e "${YELLOW}  [!] Update available: v$remote_version  →  Run: cd nw-osint-tool && git pull${RESET}"
        sleep 2
    else
        echo -e "${GREEN}  [✓] Tool is up to date (v$current_version)${RESET}"
    fi
}

# ─────────────────────────────────────────
# MODULE 1: USERNAME OSINT
# FIX: replaced declare -A (broken on some Termux bash) with parallel arrays
# ─────────────────────────────────────────
username_osint() {
    banner
    section "USERNAME OSINT"
    echo -ne "${GREEN}  [?] Enter username: ${RESET}"
    read -r username

    [ -z "$username" ] && echo -e "${RED}  [!] No username entered.${RESET}" && press_enter && return

    echo -e "\n${CYAN}  [*] Searching: ${WHITE}$username${RESET}\n"

    local pnames=(
        "GitHub" "GitLab" "Twitter/X" "Instagram" "Reddit"
        "TikTok" "YouTube" "Pinterest" "Telegram" "Medium"
        "Dev.to" "Keybase" "Pastebin" "HackerNews" "Steam"
        "Twitch" "Linktree" "Replit" "Snapchat" "Mastodon"
    )
    local purls=(
        "https://github.com/$username"
        "https://gitlab.com/$username"
        "https://twitter.com/$username"
        "https://www.instagram.com/$username"
        "https://www.reddit.com/user/$username"
        "https://www.tiktok.com/@$username"
        "https://www.youtube.com/@$username"
        "https://www.pinterest.com/$username"
        "https://t.me/$username"
        "https://medium.com/@$username"
        "https://dev.to/$username"
        "https://keybase.io/$username"
        "https://pastebin.com/u/$username"
        "https://news.ycombinator.com/user?id=$username"
        "https://steamcommunity.com/id/$username"
        "https://www.twitch.tv/$username"
        "https://linktr.ee/$username"
        "https://replit.com/@$username"
        "https://www.snapchat.com/add/$username"
        "https://mastodon.social/@$username"
    )

    local found=0 not_found=0 results=""
    local total=${#pnames[@]}

    for (( i=0; i<total; i++ )); do
        local pname="${pnames[$i]}"
        local purl="${purls[$i]}"
        local status
        status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 8 -L "$purl" \
            -H "User-Agent: Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36")
        if [[ "$status" == "200" || "$status" == "301" || "$status" == "302" ]]; then
            echo -e "  ${GREEN}[✓] FOUND   ${WHITE}$pname${RESET} → ${DIM}$purl${RESET}"
            results+="[FOUND] $pname: $purl\n"
            ((found++))
        else
            echo -e "  ${RED}[✗]${RESET} ${DIM}$pname${RESET}"
            ((not_found++))
        fi
    done

    echo -e "\n${YELLOW}  ─────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}Found: $found${RESET} | ${RED}Not Found: $not_found${RESET}"
    save_report "username_${username}" "$results"
    log_result "username" "$username" "$results"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 2: IP ADDRESS OSINT
# ─────────────────────────────────────────
ip_osint() {
    banner
    section "IP ADDRESS OSINT"
    echo -ne "${GREEN}  [?] Enter IP (or press Enter for your IP): ${RESET}"
    read -r ip

    if [ -z "$ip" ]; then
        ip=$(curl -s --max-time 8 https://api.ipify.org 2>/dev/null | tr -d '[:space:]')
        if [ -z "$ip" ]; then
            echo -e "${RED}  [!] Could not fetch your public IP. Check connection.${RESET}"
            press_enter; return
        fi
        echo -e "${CYAN}  [*] Your public IP: ${WHITE}$ip${RESET}"
    fi

    if ! echo "$ip" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
        echo -e "${RED}  [!] Invalid IP format. Example: 8.8.8.8${RESET}"
        press_enter; return
    fi

    echo -e "\n${CYAN}  [*] Looking up: ${WHITE}$ip${RESET}\n"

    local result
    result=$(curl -s --max-time 10 \
        "http://ip-api.com/json/$ip?fields=status,message,country,countryCode,regionName,city,zip,lat,lon,timezone,isp,org,as,reverse,mobile,proxy,hosting,query")

    if echo "$result" | jq -e '.status == "success"' &>/dev/null; then
        echo -e "  ${GREEN}┌─ IP INFO ────────────────────────────────┐${RESET}"
        echo -e "  ${WHITE}│ IP Address  :${RESET} $(echo "$result" | jq -r '.query')"
        echo -e "  ${WHITE}│ Country     :${RESET} $(echo "$result" | jq -r '.country') ($(echo "$result" | jq -r '.countryCode'))"
        echo -e "  ${WHITE}│ Region      :${RESET} $(echo "$result" | jq -r '.regionName')"
        echo -e "  ${WHITE}│ City        :${RESET} $(echo "$result" | jq -r '.city')"
        echo -e "  ${WHITE}│ ZIP         :${RESET} $(echo "$result" | jq -r '.zip')"
        echo -e "  ${WHITE}│ Latitude    :${RESET} $(echo "$result" | jq -r '.lat')"
        echo -e "  ${WHITE}│ Longitude   :${RESET} $(echo "$result" | jq -r '.lon')"
        echo -e "  ${WHITE}│ Timezone    :${RESET} $(echo "$result" | jq -r '.timezone')"
        echo -e "  ${WHITE}│ ISP         :${RESET} $(echo "$result" | jq -r '.isp')"
        echo -e "  ${WHITE}│ Org         :${RESET} $(echo "$result" | jq -r '.org')"
        echo -e "  ${WHITE}│ AS          :${RESET} $(echo "$result" | jq -r '.as')"
        echo -e "  ${WHITE}│ Reverse DNS :${RESET} $(echo "$result" | jq -r '.reverse')"
        echo -e "  ${WHITE}│ Mobile      :${RESET} $(echo "$result" | jq -r '.mobile')"
        echo -e "  ${WHITE}│ Proxy/VPN   :${RESET} $(echo "$result" | jq -r '.proxy')"
        echo -e "  ${WHITE}│ Hosting     :${RESET} $(echo "$result" | jq -r '.hosting')"
        echo -e "  ${GREEN}└─────────────────────────────────────────┘${RESET}"

        local lat lon
        lat=$(echo "$result" | jq -r '.lat')
        lon=$(echo "$result" | jq -r '.lon')
        echo -e "\n  ${CYAN}[🗺] Map:${RESET} https://www.openstreetmap.org/?mlat=$lat&mlon=$lon"

        save_report "ip_${ip}" "$(echo "$result" | jq .)"
        log_result "ip" "$ip" "$result"
    else
        local msg
        msg=$(echo "$result" | jq -r '.message // "Unknown error"')
        echo -e "${RED}  [!] Failed: $msg${RESET}"
    fi
    press_enter
}

# ─────────────────────────────────────────
# MODULE 3: DOMAIN OSINT
# ─────────────────────────────────────────
domain_osint() {
    banner
    section "DOMAIN / WEBSITE OSINT"
    echo -ne "${GREEN}  [?] Enter domain (e.g. example.com): ${RESET}"
    read -r input_domain

    [ -z "$input_domain" ] && echo -e "${RED}  [!] No domain entered.${RESET}" && press_enter && return

    # Strip protocol and path
    local target_domain
    target_domain=$(echo "$input_domain" | sed 's|https://||;s|http://||;s|/.*||' | tr -d '[:space:]')

    echo -e "\n${CYAN}  [*] Gathering info for: ${WHITE}$target_domain${RESET}\n"

    echo -e "${YELLOW}  ── WHOIS ───────────────────────────────────${RESET}"
    local whois_result
    whois_result=$(whois "$target_domain" 2>/dev/null)
    if [ -n "$whois_result" ]; then
        echo "$whois_result" | grep -iE "registrar|creation|expir|updated|name server|status|registrant|country|email" | \
            grep -v "^%" | head -20
    else
        echo -e "  ${RED}[!] WHOIS lookup failed${RESET}"
    fi

    echo -e "\n${YELLOW}  ── DNS RECORDS ─────────────────────────────${RESET}"
    echo -e "${WHITE}  [A Record]${RESET}"
    nslookup -type=A "$target_domain" 2>/dev/null | grep "Address:" | grep -v "#" | grep -v "127\." | head -5
    echo -e "${WHITE}  [MX Record]${RESET}"
    nslookup -type=MX "$target_domain" 2>/dev/null | grep -i "mail\|exchanger" | head -5
    echo -e "${WHITE}  [TXT Record]${RESET}"
    nslookup -type=TXT "$target_domain" 2>/dev/null | grep "text =" | head -5
    echo -e "${WHITE}  [NS Record]${RESET}"
    nslookup -type=NS "$target_domain" 2>/dev/null | grep "nameserver\|name server" | head -5

    echo -e "\n${YELLOW}  ── IP & GEO ────────────────────────────────${RESET}"
    local domain_ip
    domain_ip=$(nslookup "$target_domain" 2>/dev/null | grep "Address:" | grep -v "#" | grep -v "127\." | tail -1 | awk '{print $2}')
    if [ -n "$domain_ip" ]; then
        echo -e "  ${WHITE}Resolved IP :${RESET} $domain_ip"
        local geo
        geo=$(curl -s --max-time 8 "http://ip-api.com/json/$domain_ip?fields=country,city,isp,org,as,proxy")
        echo -e "  ${WHITE}Country     :${RESET} $(echo "$geo" | jq -r '.country')"
        echo -e "  ${WHITE}City        :${RESET} $(echo "$geo" | jq -r '.city')"
        echo -e "  ${WHITE}ISP         :${RESET} $(echo "$geo" | jq -r '.isp')"
        echo -e "  ${WHITE}Org         :${RESET} $(echo "$geo" | jq -r '.org')"
        echo -e "  ${WHITE}Proxy/VPN   :${RESET} $(echo "$geo" | jq -r '.proxy')"
    else
        echo -e "  ${RED}[!] Could not resolve domain to IP${RESET}"
    fi

    echo -e "\n${YELLOW}  ── SUBDOMAIN SCAN ──────────────────────────${RESET}"
    local subs=("www" "mail" "ftp" "admin" "webmail" "portal" "api" "dev" "staging" "blog" "shop" "vpn" "remote" "app" "cpanel" "smtp" "pop" "imap" "cdn" "static")
    local found_subs=0
    for sub in "${subs[@]}"; do
        local sub_ip
        sub_ip=$(nslookup "$sub.$target_domain" 2>/dev/null | grep "Address:" | grep -v "#" | grep -v "127\." | tail -1 | awk '{print $2}')
        if [ -n "$sub_ip" ]; then
            echo -e "  ${GREEN}[✓]${RESET} $sub.$target_domain → $sub_ip"
            ((found_subs++))
        fi
    done
    [ $found_subs -eq 0 ] && echo -e "  ${DIM}  No common subdomains resolved${RESET}"

    echo -e "\n${YELLOW}  ── HTTP HEADERS ────────────────────────────${RESET}"
    curl -sI "https://$target_domain" --max-time 8 -L \
        -H "User-Agent: Mozilla/5.0" | \
        grep -iE "server|x-powered|content-type|strict-transport|x-frame|cf-ray|x-cache|via" | head -10

    echo -e "\n${YELLOW}  ── ROBOTS.TXT ──────────────────────────────${RESET}"
    local robots
    robots=$(curl -s "https://$target_domain/robots.txt" --max-time 8 -L 2>/dev/null)
    if [ -n "$robots" ]; then
        echo "$robots" | head -20
    else
        echo -e "  ${DIM}  robots.txt not found or inaccessible${RESET}"
    fi

    log_result "domain" "$target_domain" "Domain recon completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 4: EMAIL OSINT
# FIX: use python3 for md5, fixed variable shadowing ($domain), fixed declare -A
# ─────────────────────────────────────────
email_osint() {
    banner
    section "EMAIL OSINT"
    echo -ne "${GREEN}  [?] Enter email address: ${RESET}"
    read -r email_input

    [ -z "$email_input" ] && echo -e "${RED}  [!] No email entered.${RESET}" && press_enter && return

    if ! echo "$email_input" | grep -qE '^[^@]+@[^@]+\.[^@]+$'; then
        echo -e "${RED}  [!] Invalid email format.${RESET}"
        press_enter; return
    fi

    local email_domain email_user
    email_domain=$(echo "$email_input" | cut -d'@' -f2)
    email_user=$(echo "$email_input" | cut -d'@' -f1)

    echo -e "\n${CYAN}  [*] Analyzing: ${WHITE}$email_input${RESET}\n"

    echo -e "${YELLOW}  ── BREAKDOWN ───────────────────────────────${RESET}"
    echo -e "  ${WHITE}Username :${RESET} $email_user"
    echo -e "  ${WHITE}Domain   :${RESET} $email_domain"

    echo -e "\n${YELLOW}  ── MX RECORD ───────────────────────────────${RESET}"
    local mx
    mx=$(nslookup -type=MX "$email_domain" 2>/dev/null | grep -i "mail\|exchanger" | head -3)
    if [ -n "$mx" ]; then
        echo -e "  ${GREEN}[✓] Valid email domain — MX records found${RESET}"
        echo "$mx"
    else
        echo -e "  ${RED}[✗] No MX records found — domain may not accept email${RESET}"
    fi

    echo -e "\n${YELLOW}  ── GRAVATAR CHECK ──────────────────────────${RESET}"
    local md5hash
    md5hash=$(make_md5 "$email_input")
    if [ -n "$md5hash" ]; then
        local grav_status
        grav_status=$(curl -o /dev/null -s -w "%{http_code}" \
            "https://www.gravatar.com/avatar/${md5hash}?d=404" --max-time 8)
        if [ "$grav_status" == "200" ]; then
            echo -e "  ${GREEN}[✓] Gravatar profile found!${RESET}"
            echo -e "  ${WHITE}Avatar  :${RESET} https://www.gravatar.com/avatar/$md5hash"
            echo -e "  ${WHITE}Profile :${RESET} https://www.gravatar.com/$md5hash"
        else
            echo -e "  ${RED}[✗] No Gravatar profile${RESET}"
        fi
    else
        echo -e "  ${DIM}  Gravatar check unavailable (python3 missing?)${RESET}"
    fi

    echo -e "\n${YELLOW}  ── BREACH CHECK ────────────────────────────${RESET}"
    echo -e "  ${DIM}  Querying HaveIBeenPwned...${RESET}"
    local breach
    breach=$(curl -s --max-time 10 \
        -H "User-Agent: NW-OSINT-Tool" \
        "https://haveibeenpwned.com/api/v3/breachedaccount/${email_input}" 2>/dev/null)
    if echo "$breach" | grep -q "Name\|Title"; then
        echo -e "  ${RED}[!] Email found in data breaches!${RESET}"
        echo "$breach" | grep -o '"Name":"[^"]*"' | sed 's/"Name":"//g;s/"//g' | head -10 | while read -r b; do
            echo -e "  ${RED}  ►${RESET} $b"
        done
    else
        echo -e "  ${GREEN}[✓] Not found in public breach databases${RESET}"
        echo -e "  ${DIM}    Verify manually: https://haveibeenpwned.com${RESET}"
    fi

    echo -e "\n${YELLOW}  ── SOCIAL CROSS-CHECK ──────────────────────${RESET}"
    local social_names=("GitHub" "Twitter/X" "Instagram" "Reddit")
    local social_urls=(
        "https://github.com/$email_user"
        "https://twitter.com/$email_user"
        "https://www.instagram.com/$email_user"
        "https://www.reddit.com/user/$email_user"
    )
    for (( i=0; i<${#social_names[@]}; i++ )); do
        local sc_status
        sc_status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 6 -L "${social_urls[$i]}" \
            -H "User-Agent: Mozilla/5.0")
        if [[ "$sc_status" == "200" ]]; then
            echo -e "  ${GREEN}[✓]${RESET} ${social_names[$i]} → ${social_urls[$i]}"
        fi
    done

    log_result "email" "$email_input" "Email OSINT completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 5: PHONE OSINT
# ─────────────────────────────────────────
phone_osint() {
    banner
    section "PHONE NUMBER OSINT"
    echo -ne "${GREEN}  [?] Enter phone with country code (e.g. +919876543210): ${RESET}"
    read -r phone

    [ -z "$phone" ] && echo -e "${RED}  [!] No number entered.${RESET}" && press_enter && return

    echo -e "\n${CYAN}  [*] Analyzing: ${WHITE}$phone${RESET}\n"

    local country_code="Unknown"
    [[ "$phone" == +880* ]] && country_code="Bangladesh 🇧🇩"
    [[ "$phone" == +966* ]] && country_code="Saudi Arabia 🇸🇦"
    [[ "$phone" == +971* ]] && country_code="UAE 🇦🇪"
    [[ "$phone" == +91*  ]] && country_code="India 🇮🇳"
    [[ "$phone" == +92*  ]] && country_code="Pakistan 🇵🇰"
    [[ "$phone" == +1*   ]] && country_code="USA / Canada 🇺🇸"
    [[ "$phone" == +44*  ]] && country_code="United Kingdom 🇬🇧"
    [[ "$phone" == +61*  ]] && country_code="Australia 🇦🇺"
    [[ "$phone" == +65*  ]] && country_code="Singapore 🇸🇬"
    [[ "$phone" == +60*  ]] && country_code="Malaysia 🇲🇾"
    [[ "$phone" == +49*  ]] && country_code="Germany 🇩🇪"
    [[ "$phone" == +33*  ]] && country_code="France 🇫🇷"
    [[ "$phone" == +81*  ]] && country_code="Japan 🇯🇵"
    [[ "$phone" == +86*  ]] && country_code="China 🇨🇳"

    local clean_phone wa_number
    clean_phone=$(echo "$phone" | tr -d '+- ()')
    wa_number=$(echo "$phone" | tr -d '+')

    echo -e "${YELLOW}  ── NUMBER INFO ─────────────────────────────${RESET}"
    echo -e "  ${WHITE}Number   :${RESET} $phone"
    echo -e "  ${WHITE}Country  :${RESET} $country_code"
    echo -e "  ${WHITE}Digits   :${RESET} ${#clean_phone}"

    echo -e "\n${YELLOW}  ── PUBLIC LOOKUP LINKS ─────────────────────${RESET}"
    echo -e "  ${WHITE}Truecaller  :${RESET} https://www.truecaller.com/search/in/$clean_phone"
    echo -e "  ${WHITE}Sync.me     :${RESET} https://sync.me/search/?number=$phone"
    echo -e "  ${WHITE}SpamCalls   :${RESET} https://www.shouldianswer.com/phone-number/$clean_phone"

    echo -e "\n${YELLOW}  ── WHATSAPP ────────────────────────────────${RESET}"
    local wa_status
    wa_status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 8 "https://wa.me/$wa_number" 2>/dev/null)
    if [[ "$wa_status" == "200" || "$wa_status" == "301" || "$wa_status" == "302" ]]; then
        echo -e "  ${GREEN}[✓] WhatsApp link is active${RESET}"
    else
        echo -e "  ${DIM}  WhatsApp status uncertain${RESET}"
    fi
    echo -e "  ${WHITE}WA Link  :${RESET} https://wa.me/$wa_number"

    echo -e "\n${YELLOW}  ── TELEGRAM ────────────────────────────────${RESET}"
    echo -e "  ${WHITE}TG Link  :${RESET} https://t.me/+$wa_number"

    log_result "phone" "$phone" "Phone OSINT completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 6: NETWORK OSINT
# FIX: fallback speed test server, safer bc/python3 math
# ─────────────────────────────────────────
network_osint() {
    banner
    section "NETWORK OSINT"
    echo -e "${CYAN}  [*] Gathering network info...\n${RESET}"

    local pub_ip
    pub_ip=$(curl -s --max-time 8 https://api.ipify.org 2>/dev/null | tr -d '[:space:]')
    if [ -z "$pub_ip" ]; then
        pub_ip=$(curl -s --max-time 8 https://ifconfig.me 2>/dev/null | tr -d '[:space:]')
    fi
    if [ -z "$pub_ip" ]; then
        echo -e "${RED}  [!] Could not fetch public IP. Check connection.${RESET}"
        press_enter; return
    fi

    echo -e "${YELLOW}  ── PUBLIC IP ───────────────────────────────${RESET}"
    echo -e "  ${WHITE}IP :${RESET} $pub_ip"

    echo -e "\n${YELLOW}  ── GEOLOCATION ─────────────────────────────${RESET}"
    local geo
    geo=$(curl -s --max-time 10 "http://ip-api.com/json/$pub_ip?fields=country,city,isp,org,as,timezone,proxy")
    echo -e "  ${WHITE}Country  :${RESET} $(echo "$geo" | jq -r '.country')"
    echo -e "  ${WHITE}City     :${RESET} $(echo "$geo" | jq -r '.city')"
    echo -e "  ${WHITE}ISP      :${RESET} $(echo "$geo" | jq -r '.isp')"
    echo -e "  ${WHITE}Org      :${RESET} $(echo "$geo" | jq -r '.org')"
    echo -e "  ${WHITE}AS       :${RESET} $(echo "$geo" | jq -r '.as')"
    echo -e "  ${WHITE}Timezone :${RESET} $(echo "$geo" | jq -r '.timezone')"
    echo -e "  ${WHITE}VPN/Proxy:${RESET} $(echo "$geo" | jq -r '.proxy')"

    echo -e "\n${YELLOW}  ── DNS LEAK TEST ───────────────────────────${RESET}"
    local dns_ip
    dns_ip=$(nslookup myip.opendns.com resolver1.opendns.com 2>/dev/null | grep "Address:" | grep -v "#" | tail -1 | awk '{print $2}')
    if [ -n "$dns_ip" ]; then
        echo -e "  ${WHITE}DNS-resolved IP :${RESET} $dns_ip"
        if [ "$pub_ip" == "$dns_ip" ]; then
            echo -e "  ${GREEN}[✓] No DNS leak detected${RESET}"
        else
            echo -e "  ${YELLOW}[!] Possible DNS leak — IPs differ${RESET}"
        fi
    else
        echo -e "  ${DIM}  DNS leak check unavailable${RESET}"
    fi

    echo -e "\n${YELLOW}  ── SPEED TEST ──────────────────────────────${RESET}"
    echo -e "  ${CYAN}Testing download speed...${RESET}"
    local speed
    # FIX: try primary server first, fallback to secondary
    speed=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 12 \
        "http://speedtest.ftp.otenet.gr/files/test1Mb.db" 2>/dev/null)
    if [ -z "$speed" ] || [ "$speed" == "0" ]; then
        speed=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 12 \
            "http://proof.ovh.net/files/1Mb.dat" 2>/dev/null)
    fi
    if [ -n "$speed" ] && [ "$speed" != "0" ]; then
        local speed_mbps
        speed_mbps=$(python3 -c "print(round($speed/1048576,2))" 2>/dev/null)
        echo -e "  ${WHITE}Download :${RESET} ~${speed_mbps} Mbps"
    else
        echo -e "  ${DIM}  Speed test unavailable${RESET}"
    fi

    echo -e "\n${YELLOW}  ── OPEN LOCAL PORTS ────────────────────────${RESET}"
    local open_count=0
    for port in 21 22 23 25 53 80 443 3306 5432 8080 8888; do
        if timeout 1 bash -c "echo >/dev/tcp/127.0.0.1/$port" 2>/dev/null; then
            echo -e "  ${GREEN}[OPEN]${RESET}  Port $port"
            ((open_count++))
        fi
    done
    [ $open_count -eq 0 ] && echo -e "  ${DIM}  No common ports open on localhost${RESET}"

    press_enter
}

# ─────────────────────────────────────────
# MODULE 7: GOOGLE DORKING
# FIX: quote handling in python3 urllib call
# ─────────────────────────────────────────
google_dork() {
    banner
    section "GOOGLE DORKING HELPER"
    echo -e "${DIM}  Auto-generates Google dork queries for OSINT${RESET}\n"
    echo -ne "${GREEN}  [?] Enter target (domain, name, or keyword): ${RESET}"
    read -r dork_target

    [ -z "$dork_target" ] && press_enter && return

    echo -e "\n${YELLOW}  ── GENERATED DORKS ─────────────────────────${RESET}\n"

    local dorks=(
        "site:$dork_target"
        "inurl:$dork_target"
        "intitle:$dork_target"
        "$dork_target filetype:pdf"
        "$dork_target filetype:doc OR filetype:docx"
        "$dork_target filetype:xls OR filetype:xlsx"
        "site:$dork_target inurl:admin"
        "site:$dork_target inurl:login"
        "site:$dork_target inurl:config"
        "site:$dork_target ext:sql OR ext:db"
        "site:$dork_target ext:log"
        "site:$dork_target ext:env OR ext:bak"
        "site:linkedin.com $dork_target"
        "site:pastebin.com $dork_target"
        "site:github.com $dork_target"
        "$dork_target email"
        "$dork_target password"
        "cache:$dork_target"
        "related:$dork_target"
    )

    local report_content=""
    for dork in "${dorks[@]}"; do
        # FIX: safe python3 encoding without nested quotes
        local encoded
        encoded=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$dork" 2>/dev/null)
        echo -e "  ${GREEN}►${RESET} ${WHITE}$dork${RESET}"
        if [ -n "$encoded" ]; then
            echo -e "    ${DIM}https://www.google.com/search?q=$encoded${RESET}\n"
            report_content+="$dork\nhttps://www.google.com/search?q=$encoded\n\n"
        else
            echo ""
            report_content+="$dork\n\n"
        fi
    done

    save_report "dorks_${dork_target}" "$report_content"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 8: WEBSITE FINGERPRINT
# FIX: $domain variable renamed, detect() scope fixed
# ─────────────────────────────────────────
tech_fingerprint() {
    banner
    section "WEBSITE TECH FINGERPRINT"
    echo -ne "${GREEN}  [?] Enter URL or domain (e.g. example.com): ${RESET}"
    read -r fp_url

    [ -z "$fp_url" ] && press_enter && return

    # Add https if missing
    [[ "$fp_url" != http* ]] && fp_url="https://$fp_url"

    echo -e "\n${CYAN}  [*] Fingerprinting: ${WHITE}$fp_url${RESET}\n"

    echo -e "${YELLOW}  ── HTTP HEADERS ────────────────────────────${RESET}"
    local fp_headers
    fp_headers=$(curl -sI "$fp_url" --max-time 10 -L \
        -H "User-Agent: Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36" 2>/dev/null)
    if [ -n "$fp_headers" ]; then
        echo "$fp_headers" | grep -iE "server|x-powered|x-generator|cf-ray|x-cache|x-drupal|x-wordpress|via|content-type|strict-transport|access-control|x-runtime"
    else
        echo -e "  ${RED}[!] No response from server${RESET}"
        press_enter; return
    fi

    echo -e "\n${YELLOW}  ── CMS & TECHNOLOGY ────────────────────────${RESET}"
    local fp_body
    fp_body=$(curl -sL "$fp_url" --max-time 10 \
        -H "User-Agent: Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36" 2>/dev/null)

    local fp_detected=0
    local combined="$fp_body$fp_headers"

    fp_check() {
        local label="$1"; shift
        for pattern in "$@"; do
            if echo "$combined" | grep -qi "$pattern"; then
                echo -e "  ${GREEN}[✓]${RESET} $label"
                ((fp_detected++))
                return 0
            fi
        done
    }

    fp_check "CMS: WordPress"      "wp-content" "wp-includes" "wordpress"
    fp_check "CMS: Drupal"         "Drupal" "drupal.js" "/sites/default"
    fp_check "CMS: Joomla"         "Joomla" "/components/com_"
    fp_check "CMS: Magento"        "Mage.Cookies" "magento"
    fp_check "Platform: Shopify"   "shopify" "cdn.shopify"
    fp_check "Platform: Wix"       "wix.com" "wixstatic"
    fp_check "Platform: Webflow"   "webflow"
    fp_check "JS: React"           "__react" "_react" "react-dom"
    fp_check "JS: Vue.js"          "__vue" "vue.runtime" "vuejs"
    fp_check "JS: Angular"         "ng-version" "angular.min.js"
    fp_check "JS: Next.js"         "__NEXT_DATA__" "_next/static"
    fp_check "JS: Nuxt.js"         "__NUXT__" "_nuxt/"
    fp_check "JS: jQuery"          "jquery.min.js" "jquery.js"
    fp_check "Analytics: Google"   "google-analytics.com" "gtag(" "GoogleAnalyticsObject"
    fp_check "Analytics: FB Pixel" "fbq(" "connect.facebook.net/en_US/fbevents"
    fp_check "CDN: Cloudflare"     "cloudflare" "cf-ray"
    fp_check "CDN: Fastly"         "fastly"
    fp_check "CDN: AWS CloudFront" "cloudfront.net"
    fp_check "Server: Nginx"       "nginx"
    fp_check "Server: Apache"      "apache"

    [ $fp_detected -eq 0 ] && echo -e "  ${DIM}  No common technologies detected${RESET}"

    echo -e "\n${YELLOW}  ── SSL CERTIFICATE ─────────────────────────${RESET}"
    local fp_domain
    fp_domain=$(echo "$fp_url" | sed 's|https://||;s|http://||;s|/.*||')
    local ssl_info
    ssl_info=$(echo | timeout 8 openssl s_client -connect "$fp_domain:443" \
        -servername "$fp_domain" 2>/dev/null | openssl x509 -noout -dates -issuer -subject 2>/dev/null)
    if [ -n "$ssl_info" ]; then
        echo "$ssl_info"
    else
        echo -e "  ${DIM}  SSL info unavailable or site is HTTP only${RESET}"
    fi

    press_enter
}

# ─────────────────────────────────────────
# MODULE 9: WAYBACK MACHINE
# FIX: snap_url scope — declare before conditional to avoid unbound variable
# ─────────────────────────────────────────
wayback_lookup() {
    banner
    section "WAYBACK MACHINE LOOKUP"
    echo -ne "${GREEN}  [?] Enter domain (e.g. example.com): ${RESET}"
    read -r wb_target

    [ -z "$wb_target" ] && press_enter && return

    wb_target=$(echo "$wb_target" | sed 's|https://||;s|http://||;s|/.*||' | tr -d '[:space:]')

    echo -e "\n${CYAN}  [*] Searching Wayback Machine for: ${WHITE}$wb_target${RESET}\n"

    echo -e "${YELLOW}  ── AVAILABILITY CHECK ──────────────────────${RESET}"
    local avail snap_url snap_time snap_status
    snap_url=""
    avail=$(curl -s --max-time 10 "https://archive.org/wayback/available?url=$wb_target" 2>/dev/null)

    if echo "$avail" | jq -e '.archived_snapshots.closest.url' &>/dev/null; then
        snap_url=$(echo "$avail" | jq -r '.archived_snapshots.closest.url')
        snap_time=$(echo "$avail" | jq -r '.archived_snapshots.closest.timestamp')
        snap_status=$(echo "$avail" | jq -r '.archived_snapshots.closest.status')
        local year="${snap_time:0:4}" month="${snap_time:4:2}" day="${snap_time:6:2}"
        echo -e "  ${GREEN}[✓] Snapshots found!${RESET}"
        echo -e "  ${WHITE}Latest Snapshot :${RESET} $year-$month-$day"
        echo -e "  ${WHITE}HTTP Status     :${RESET} $snap_status"
        echo -e "  ${WHITE}Archived URL    :${RESET} $snap_url"
    else
        echo -e "  ${RED}[✗] No snapshots found for $wb_target${RESET}"
    fi

    echo -e "\n${YELLOW}  ── SNAPSHOT HISTORY LINKS ──────────────────${RESET}"
    echo -e "  ${WHITE}All snapshots :${RESET} https://web.archive.org/web/*/$wb_target"
    echo -e "  ${WHITE}Year 2022     :${RESET} https://web.archive.org/web/2022*/$wb_target"
    echo -e "  ${WHITE}Year 2020     :${RESET} https://web.archive.org/web/2020*/$wb_target"
    echo -e "  ${WHITE}Year 2018     :${RESET} https://web.archive.org/web/2018*/$wb_target"
    echo -e "  ${WHITE}Year 2015     :${RESET} https://web.archive.org/web/2015*/$wb_target"
    echo -e "  ${WHITE}Oldest        :${RESET} https://web.archive.org/web/19960101000000*/$wb_target"

    echo -e "\n${YELLOW}  ── TOTAL CRAWL COUNT ───────────────────────${RESET}"
    echo -e "  ${CYAN}Fetching...${RESET}"
    local cdx
    cdx=$(curl -s --max-time 10 \
        "https://web.archive.org/cdx/search/cdx?url=$wb_target&output=json&showNumPages=true" 2>/dev/null)
    # FIX: CDX returns a plain number, check it's actually a number
    if echo "$cdx" | grep -qE '^[0-9]+$'; then
        echo -e "  ${WHITE}Total archived pages :${RESET} $cdx"
    else
        echo -e "  ${DIM}  Count unavailable${RESET}"
    fi

    # FIX: only use snap_url in report if it was actually set
    local report_content="Wayback lookup for: $wb_target\n"
    if [ -n "$snap_url" ]; then
        report_content+="Latest snapshot: $snap_url\n"
    fi

    save_report "wayback_${wb_target}" "$report_content"
    log_result "wayback" "$wb_target" "Wayback lookup completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 10: GITHUB OSINT
# ─────────────────────────────────────────
github_osint() {
    banner
    section "GITHUB OSINT"
    echo -ne "${GREEN}  [?] Enter GitHub username or org name: ${RESET}"
    read -r ghuser

    [ -z "$ghuser" ] && press_enter && return

    echo -e "\n${CYAN}  [*] Fetching GitHub data for: ${WHITE}$ghuser${RESET}\n"

    echo -e "${YELLOW}  ── PROFILE ─────────────────────────────────${RESET}"
    local profile
    profile=$(curl -s --max-time 10 "https://api.github.com/users/$ghuser" \
        -H "Accept: application/vnd.github.v3+json" 2>/dev/null)

    if echo "$profile" | jq -e '.login' &>/dev/null; then
        echo -e "  ${WHITE}Name        :${RESET} $(echo "$profile" | jq -r '.name // "N/A"')"
        echo -e "  ${WHITE}Bio         :${RESET} $(echo "$profile" | jq -r '.bio // "N/A"')"
        echo -e "  ${WHITE}Location    :${RESET} $(echo "$profile" | jq -r '.location // "N/A"')"
        echo -e "  ${WHITE}Company     :${RESET} $(echo "$profile" | jq -r '.company // "N/A"')"
        echo -e "  ${WHITE}Email       :${RESET} $(echo "$profile" | jq -r '.email // "N/A"')"
        echo -e "  ${WHITE}Website     :${RESET} $(echo "$profile" | jq -r '.blog // "N/A"')"
        echo -e "  ${WHITE}Twitter     :${RESET} $(echo "$profile" | jq -r '.twitter_username // "N/A"')"
        echo -e "  ${WHITE}Public Repos:${RESET} $(echo "$profile" | jq -r '.public_repos')"
        echo -e "  ${WHITE}Followers   :${RESET} $(echo "$profile" | jq -r '.followers')"
        echo -e "  ${WHITE}Following   :${RESET} $(echo "$profile" | jq -r '.following')"
        echo -e "  ${WHITE}Joined      :${RESET} $(echo "$profile" | jq -r '.created_at')"
        echo -e "  ${WHITE}Last Active :${RESET} $(echo "$profile" | jq -r '.updated_at')"
        echo -e "  ${WHITE}Type        :${RESET} $(echo "$profile" | jq -r '.type')"
    else
        local gh_err
        gh_err=$(echo "$profile" | jq -r '.message // "User not found"')
        echo -e "  ${RED}[!] $gh_err${RESET}"
        press_enter; return
    fi

    echo -e "\n${YELLOW}  ── REPOSITORIES (latest 10) ────────────────${RESET}"
    local repos_data
    repos_data=$(curl -s --max-time 10 \
        "https://api.github.com/users/$ghuser/repos?sort=updated&per_page=10" \
        -H "Accept: application/vnd.github.v3+json" 2>/dev/null)
    if echo "$repos_data" | jq -e '.[0]' &>/dev/null; then
        echo "$repos_data" | jq -r \
            '.[] | "  ► \(.name) [\(.language // "N/A")] ⭐\(.stargazers_count) — \(.description // "No description")"' | head -10
    else
        echo -e "  ${DIM}  No public repos or API limit reached${RESET}"
    fi

    echo -e "\n${YELLOW}  ── ORGANIZATIONS ───────────────────────────${RESET}"
    local orgs
    orgs=$(curl -s --max-time 8 \
        "https://api.github.com/users/$ghuser/orgs" \
        -H "Accept: application/vnd.github.v3+json" 2>/dev/null)
    if echo "$orgs" | jq -e '.[0]' &>/dev/null; then
        echo "$orgs" | jq -r '.[].login' | while read -r org; do
            echo -e "  ${GREEN}[✓]${RESET} $org"
        done
    else
        echo -e "  ${DIM}  No public organizations${RESET}"
    fi

    echo -e "\n${YELLOW}  ── GISTS ───────────────────────────────────${RESET}"
    local gists
    gists=$(curl -s --max-time 8 \
        "https://api.github.com/users/$ghuser/gists?per_page=5" \
        -H "Accept: application/vnd.github.v3+json" 2>/dev/null)
    if echo "$gists" | jq -e '.[0]' &>/dev/null; then
        echo "$gists" | jq -r '.[] | "  ► \(.description // "No description") — \(.html_url)"' | head -5
    else
        echo -e "  ${DIM}  No public gists${RESET}"
    fi

    echo -e "\n${YELLOW}  ── PROFILE LINK ────────────────────────────${RESET}"
    echo -e "  ${WHITE}GitHub :${RESET} https://github.com/$ghuser"

    save_report "github_${ghuser}" "$(echo "$profile" | jq .)"
    log_result "github" "$ghuser" "GitHub OSINT completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 11: SHODAN LOOKUP
# FIX: config overwrites key cleanly instead of appending duplicates
# ─────────────────────────────────────────
shodan_lookup() {
    banner
    section "SHODAN LOOKUP"

    local shodan_key=""

    # FIX: read only SHODAN_API line, not whole file
    if [ -f "$CONFIG_FILE" ]; then
        shodan_key=$(grep "^SHODAN_API=" "$CONFIG_FILE" 2>/dev/null | tail -1 | cut -d'=' -f2-)
    fi

    if [ -z "$shodan_key" ]; then
        echo -e "${YELLOW}  [!] No Shodan API key saved.${RESET}"
        echo -e "${DIM}  Shodan is free to sign up — get your API key at:${RESET}"
        echo -e "${WHITE}  https://account.shodan.io/register${RESET}\n"
        echo -ne "${GREEN}  [?] Enter your Shodan API key (or press Enter to skip): ${RESET}"
        read -r input_key

        if [ -z "$input_key" ]; then
            echo -e "\n${CYAN}  [*] Skipped. Sign up and come back with your API key.${RESET}"
            press_enter; return
        fi

        echo -e "\n${CYAN}  [*] Verifying API key...${RESET}"
        local verify
        verify=$(curl -s --max-time 10 "https://api.shodan.io/api-info?key=$input_key" 2>/dev/null)

        if echo "$verify" | jq -e '.query_credits' &>/dev/null; then
            local credits
            credits=$(echo "$verify" | jq -r '.query_credits')
            echo -e "  ${GREEN}[✓] Valid API key — Query credits: $credits${RESET}"

            # FIX: overwrite cleanly — remove old entry first, then append
            if [ -f "$CONFIG_FILE" ]; then
                grep -v "^SHODAN_API=" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" 2>/dev/null && \
                    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
            fi
            echo "SHODAN_API=$input_key" >> "$CONFIG_FILE"
            shodan_key="$input_key"
        else
            local sh_err
            sh_err=$(echo "$verify" | jq -r '.error // "Invalid or expired key"')
            echo -e "  ${RED}[!] Key rejected: $sh_err${RESET}"
            echo -e "  ${DIM}  Get your key: https://account.shodan.io${RESET}"
            press_enter; return
        fi
    else
        echo -e "  ${GREEN}[✓] Saved API key loaded${RESET}"
    fi

    echo ""
    echo -ne "${GREEN}  [?] Enter IP address to look up: ${RESET}"
    read -r sh_ip

    [ -z "$sh_ip" ] && press_enter && return

    if ! echo "$sh_ip" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
        echo -e "${RED}  [!] Invalid IP format. Example: 8.8.8.8${RESET}"
        press_enter; return
    fi

    echo -e "\n${CYAN}  [*] Querying Shodan for: ${WHITE}$sh_ip${RESET}\n"

    local sh_result
    sh_result=$(curl -s --max-time 15 "https://api.shodan.io/shodan/host/$sh_ip?key=$shodan_key" 2>/dev/null)

    if echo "$sh_result" | jq -e '.ip_str' &>/dev/null; then
        echo -e "${YELLOW}  ── HOST INFO ───────────────────────────────${RESET}"
        echo -e "  ${WHITE}IP           :${RESET} $(echo "$sh_result" | jq -r '.ip_str')"
        echo -e "  ${WHITE}Organization :${RESET} $(echo "$sh_result" | jq -r '.org // "N/A"')"
        echo -e "  ${WHITE}ISP          :${RESET} $(echo "$sh_result" | jq -r '.isp // "N/A"')"
        echo -e "  ${WHITE}Country      :${RESET} $(echo "$sh_result" | jq -r '.country_name // "N/A"')"
        echo -e "  ${WHITE}City         :${RESET} $(echo "$sh_result" | jq -r '.city // "N/A"')"
        echo -e "  ${WHITE}OS           :${RESET} $(echo "$sh_result" | jq -r '.os // "N/A"')"
        echo -e "  ${WHITE}Last Updated :${RESET} $(echo "$sh_result" | jq -r '.last_update // "N/A"')"

        echo -e "\n${YELLOW}  ── OPEN PORTS ──────────────────────────────${RESET}"
        local sh_ports
        sh_ports=$(echo "$sh_result" | jq -r '.ports[]?' 2>/dev/null)
        if [ -n "$sh_ports" ]; then
            echo "$sh_ports" | while read -r p; do
                echo -e "  ${GREEN}[OPEN]${RESET} Port $p"
            done
        else
            echo -e "  ${DIM}  No port data${RESET}"
        fi

        echo -e "\n${YELLOW}  ── HOSTNAMES ───────────────────────────────${RESET}"
        local sh_hosts
        sh_hosts=$(echo "$sh_result" | jq -r '.hostnames[]?' 2>/dev/null)
        if [ -n "$sh_hosts" ]; then
            echo "$sh_hosts" | while read -r h; do echo -e "  ${WHITE}►${RESET} $h"; done
        else
            echo -e "  ${DIM}  No hostnames${RESET}"
        fi

        echo -e "\n${YELLOW}  ── VULNERABILITIES ─────────────────────────${RESET}"
        local sh_vulns
        sh_vulns=$(echo "$sh_result" | jq -r '.vulns | keys[]?' 2>/dev/null)
        if [ -n "$sh_vulns" ]; then
            echo "$sh_vulns" | while read -r v; do echo -e "  ${RED}[CVE]${RESET} $v"; done
        else
            echo -e "  ${GREEN}  No known CVEs listed${RESET}"
        fi

        echo -e "\n${YELLOW}  ── SERVICE BANNERS ─────────────────────────${RESET}"
        echo "$sh_result" | jq -r \
            '.data[]? | "  Port \(.port)/\(.transport // "tcp") — \(.product // "unknown") \(.version // "")"' \
            2>/dev/null | head -5

        save_report "shodan_${sh_ip}" "$(echo "$sh_result" | jq .)"
        log_result "shodan" "$sh_ip" "Shodan lookup completed"
    else
        local sh_err
        sh_err=$(echo "$sh_result" | jq -r '.error // "No data found for this IP"')
        echo -e "  ${RED}[!] $sh_err${RESET}"
        if echo "$sh_err" | grep -qi "credit\|limit\|quota"; then
            echo -e "  ${YELLOW}  Query credits exhausted. Upgrade at shodan.io${RESET}"
        fi
    fi

    press_enter
}

# ─────────────────────────────────────────
# MODULE 12: VIEW REPORTS
# FIX: proper array indexing for file selection
# ─────────────────────────────────────────
view_reports() {
    banner
    section "SAVED REPORTS"

    shopt -s nullglob
    local files=("$REPORT_DIR"/*)
    shopt -u nullglob

    if [ ${#files[@]} -eq 0 ]; then
        echo -e "  ${YELLOW}[!] No reports saved yet. Run some modules first.${RESET}"
        press_enter; return
    fi

    echo -e "  ${WHITE}Saved in:${RESET} ${CYAN}$REPORT_DIR${RESET}\n"
    local i=1
    for f in "${files[@]}"; do
        local fname fsize
        fname=$(basename "$f")
        fsize=$(wc -c < "$f" 2>/dev/null || echo "?")
        echo -e "  ${GREEN}[$i]${RESET} $fname ${DIM}(${fsize} bytes)${RESET}"
        ((i++))
    done

    echo ""
    echo -ne "${GREEN}  [?] Enter number to view (0 = back): ${RESET}"
    read -r rchoice

    if [[ "$rchoice" =~ ^[0-9]+$ ]] && [ "$rchoice" -gt 0 ] && [ "$rchoice" -lt "$i" ]; then
        local selected="${files[$((rchoice-1))]}"
        echo -e "\n${CYAN}  ── $(basename "$selected") ───${RESET}\n"
        cat "$selected"
    fi
    press_enter
}

# ─────────────────────────────────────────
# MAIN MENU
# ─────────────────────────────────────────
main_menu() {
    while true; do
        banner
        echo -e "  ${WHITE}${BOLD}  MODULES${RESET}\n"
        echo -e "  ${RED}[01]${RESET} ${WHITE}Username OSINT${RESET}          ${DIM}Search across 20+ platforms${RESET}"
        echo -e "  ${RED}[02]${RESET} ${WHITE}IP Address OSINT${RESET}         ${DIM}Geolocate & analyze any IP${RESET}"
        echo -e "  ${RED}[03]${RESET} ${WHITE}Domain / Website OSINT${RESET}   ${DIM}WHOIS, DNS, subdomains, headers${RESET}"
        echo -e "  ${RED}[04]${RESET} ${WHITE}Email OSINT${RESET}              ${DIM}Breach check, Gravatar, MX lookup${RESET}"
        echo -e "  ${RED}[05]${RESET} ${WHITE}Phone Number OSINT${RESET}       ${DIM}Carrier, country, WA/TG check${RESET}"
        echo -e "  ${RED}[06]${RESET} ${WHITE}Network OSINT${RESET}            ${DIM}IP, DNS leak, speed, open ports${RESET}"
        echo -e "  ${RED}[07]${RESET} ${WHITE}Google Dorking${RESET}           ${DIM}Auto-generate dork queries${RESET}"
        echo -e "  ${RED}[08]${RESET} ${WHITE}Website Fingerprint${RESET}      ${DIM}CMS, frameworks, CDN, SSL${RESET}"
        echo -e "  ${RED}[09]${RESET} ${WHITE}Wayback Machine${RESET}          ${DIM}View archived site snapshots${RESET}"
        echo -e "  ${RED}[10]${RESET} ${WHITE}GitHub OSINT${RESET}             ${DIM}Profile, repos, gists, orgs${RESET}"
        echo -e "  ${RED}[11]${RESET} ${WHITE}Shodan Lookup${RESET}            ${DIM}Exposed devices & CVEs${RESET}"
        echo -e "  ${RED}[12]${RESET} ${WHITE}View Reports${RESET}             ${DIM}Browse all saved results${RESET}"
        echo -e "  ${RED}[00]${RESET} ${WHITE}Exit${RESET}"
        echo ""
        echo -e "  ${DIM}────────────────────────────────────────────────${RESET}"
        echo -ne "  ${GREEN}NIGHTWALKER${RESET}${CYAN}@nw-osint:~# ${RESET}"
        read -r choice

        case "$choice" in
            01|1)  username_osint ;;
            02|2)  ip_osint ;;
            03|3)  domain_osint ;;
            04|4)  email_osint ;;
            05|5)  phone_osint ;;
            06|6)  network_osint ;;
            07|7)  google_dork ;;
            08|8)  tech_fingerprint ;;
            09|9)  wayback_lookup ;;
            10)    github_osint ;;
            11)    shodan_lookup ;;
            12)    view_reports ;;
            00|0|exit|quit)
                banner
                echo -e "  ${RED}  Goodbye. Stay ethical, NIGHTWALKER.${RESET}\n"
                exit 0 ;;
            *)
                echo -e "  ${RED}  [!] Invalid option.${RESET}"
                sleep 1 ;;
        esac
    done
}

# ─────────────────────────────────────────
# STARTUP
# ─────────────────────────────────────────
banner
echo -e "  ${CYAN}[*] Checking dependencies...${RESET}"
check_deps
echo -e "  ${CYAN}[*] Checking for updates...${RESET}"
check_update
sleep 1
main_menu
