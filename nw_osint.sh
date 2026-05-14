#!/bin/bash

# ============================================================
#         NW OSINT TOOL - by NIGHTWALKER
#         Termux OSINT Framework | Ethical Use Only
#         Version: 2.0
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
HISTORY_FILE="$TOOL_DIR/history.log"
CONFIG_FILE="$TOOL_DIR/config"
TEMP_DIR="$TOOL_DIR/tmp"
mkdir -p "$LOG_DIR" "$REPORT_DIR" "$TEMP_DIR"

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
    local module="$1" query="$2" result="$3"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    {
        echo "[$timestamp] Query: $query"
        echo "$result"
        echo "---"
    } >> "$LOG_DIR/${module}_$(date '+%Y%m%d').log"
}

save_report() {
    local name="$1" content="$2"
    local report="$REPORT_DIR/${name}_$(date '+%Y%m%d_%H%M%S').txt"
    printf "%b" "$content" > "$report"
    echo -e "\n${CYAN}  [✓] Report saved: ${WHITE}$report${RESET}"
}

# Search history tracker
add_history() {
    local module="$1" query="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$module] $query" >> "$HISTORY_FILE"
}

# Pure python3 md5 — md5sum not reliable on all Termux builds
make_md5() {
    python3 -c "import hashlib,sys; print(hashlib.md5(sys.argv[1].encode()).hexdigest())" "$1" 2>/dev/null
}

# Progress bar for parallel scans
show_progress() {
    local current="$1" total="$2" label="${3:-Scanning}"
    [ "$total" -eq 0 ] && return
    local pct=$(( current * 100 / total ))
    local filled=$(( pct / 5 ))
    local bar=""
    for ((i=0;i<filled;i++)); do bar+="█"; done
    for ((i=filled;i<20;i++)); do bar+="░"; done
    printf "\r  ${CYAN}[%s] %d/%d (%d%%) %s${RESET}" "$bar" "$current" "$total" "$pct" "$label"
}

# ─────────────────────────────────────────
# DEPENDENCY CHECK
# ─────────────────────────────────────────
check_deps() {
    local missing=()
    for dep in curl jq whois nslookup wget openssl python3 zip; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}  [!] Missing: ${missing[*]}${RESET}"
        echo -e "${CYAN}  [*] Installing dependencies...${RESET}"
        pkg install -y curl jq whois dnsutils wget openssl-tool python zip 2>/dev/null
        echo -e "${GREEN}  [✓] Done.${RESET}"
    fi
}

# ─────────────────────────────────────────
# UPDATE CHECKER
# ─────────────────────────────────────────
check_update() {
    local current_version="2.0"
    local remote_version
    remote_version=$(curl -s --max-time 5 \
        "https://raw.githubusercontent.com/NIGHTWALKEROFC/nw-osint-tool/main/version.txt" \
        2>/dev/null | tr -d '[:space:]')
    if [ -n "$remote_version" ] && [ "$remote_version" != "$current_version" ]; then
        echo -e "${YELLOW}  [!] Update available: v$remote_version  →  Run: cd nw-osint-tool && git pull${RESET}"
        sleep 2
    else
        echo -e "${GREEN}  [✓] Tool is up to date (v$current_version)${RESET}"
    fi
}

# ─────────────────────────────────────────
# MODULE 1: USERNAME OSINT (PARALLEL)
# ─────────────────────────────────────────
username_osint() {
    banner
    section "USERNAME OSINT"
    echo -ne "${GREEN}  [?] Enter username: ${RESET}"
    read -r username

    [ -z "$username" ] && echo -e "${RED}  [!] No username entered.${RESET}" && press_enter && return

    add_history "USERNAME" "$username"

    local pnames=(
        "GitHub" "GitLab" "Twitter/X" "Instagram" "Reddit"
        "TikTok" "YouTube" "Pinterest" "Telegram" "Medium"
        "Dev.to" "Keybase" "Pastebin" "HackerNews" "Steam"
        "Twitch" "Linktree" "Replit" "Snapchat" "Mastodon"
        "Spotify" "SoundCloud" "Behance" "Dribbble" "Fiverr"
        "ProductHunt" "Hackernoon" "Quora" "Flipboard" "Mix"
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
        "https://open.spotify.com/user/$username"
        "https://soundcloud.com/$username"
        "https://www.behance.net/$username"
        "https://dribbble.com/$username"
        "https://www.fiverr.com/$username"
        "https://www.producthunt.com/@$username"
        "https://hackernoon.com/u/$username"
        "https://www.quora.com/profile/$username"
        "https://flipboard.com/@$username"
        "https://mix.com/$username"
    )

    local total=${#pnames[@]}
    echo -e "\n${CYAN}  [*] Scanning ${WHITE}$username${CYAN} across ${WHITE}$total${CYAN} platforms (parallel)...${RESET}\n"

    # Parallel scanning using background jobs + temp files
    local results_dir="$TEMP_DIR/uscan_$$"
    mkdir -p "$results_dir"

    for (( idx=0; idx<total; idx++ )); do
        (
            local status
            status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 8 -L "${purls[$idx]}" \
                -H "User-Agent: Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36" 2>/dev/null)
            if [[ "$status" == "200" || "$status" == "301" || "$status" == "302" ]]; then
                echo "FOUND|${pnames[$idx]}|${purls[$idx]}" > "$results_dir/$idx"
            else
                echo "NOTFOUND|${pnames[$idx]}|${purls[$idx]}" > "$results_dir/$idx"
            fi
        ) &
    done

    # Progress bar while waiting — loop until all jobs done
    local completed=0
    while true; do
        completed=$(ls "$results_dir" 2>/dev/null | wc -l)
        show_progress "$completed" "$total" "checking platforms"
        [ "$completed" -ge "$total" ] && break
        sleep 0.4
    done
    wait
    printf "\n\n"

    # Display results sorted: found first
    local found=0 not_found=0 report_content=""
    for (( idx=0; idx<total; idx++ )); do
        if [ -f "$results_dir/$idx" ]; then
            local line
            line=$(cat "$results_dir/$idx")
            local status="${line%%|*}"
            local rest="${line#*|}"
            local pname="${rest%%|*}"
            local purl="${rest#*|}"
            if [ "$status" == "FOUND" ]; then
                echo -e "  ${GREEN}[✓] FOUND   ${WHITE}$pname${RESET} → ${DIM}$purl${RESET}"
                report_content+="[FOUND] $pname: $purl\n"
                ((found++))
            fi
        fi
    done
    for (( idx=0; idx<total; idx++ )); do
        if [ -f "$results_dir/$idx" ]; then
            local line
            line=$(cat "$results_dir/$idx")
            local status="${line%%|*}"
            local pname="${line#*|}"
            pname="${pname%%|*}"
            if [ "$status" == "NOTFOUND" ]; then
                echo -e "  ${RED}[✗]${RESET} ${DIM}$pname${RESET}"
                ((not_found++))
            fi
        fi
    done

    rm -rf "$results_dir"

    echo -e "\n${YELLOW}  ─────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}Found: $found${RESET} | ${RED}Not Found: $not_found${RESET} | ${WHITE}Total: $total${RESET}"
    save_report "username_${username}" "$report_content"
    log_result "username" "$username" "$report_content"
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
        [ -z "$ip" ] && ip=$(curl -s --max-time 8 https://ifconfig.me 2>/dev/null | tr -d '[:space:]')
        if [ -z "$ip" ]; then
            echo -e "${RED}  [!] Could not fetch your public IP.${RESET}"
            press_enter; return
        fi
        echo -e "${CYAN}  [*] Your public IP: ${WHITE}$ip${RESET}"
    fi

    if ! echo "$ip" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
        echo -e "${RED}  [!] Invalid IP format. Example: 8.8.8.8${RESET}"
        press_enter; return
    fi

    add_history "IP" "$ip"
    echo -e "\n${CYAN}  [*] Looking up: ${WHITE}$ip${RESET}\n"

    local result
    result=$(curl -s --max-time 10 \
        "http://ip-api.com/json/$ip?fields=status,message,country,countryCode,regionName,city,zip,lat,lon,timezone,isp,org,as,reverse,mobile,proxy,hosting,query" 2>/dev/null)

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

        # AbuseIPDB check
        echo -e "\n${YELLOW}  ── ABUSE REPUTATION ────────────────────────${RESET}"
        local abuse_key=""
        [ -f "$CONFIG_FILE" ] && abuse_key=$(grep "^ABUSEIPDB_API=" "$CONFIG_FILE" 2>/dev/null | tail -1 | cut -d'=' -f2-)

        if [ -n "$abuse_key" ]; then
            local abuse_result
            abuse_result=$(curl -s --max-time 10 \
                "https://api.abuseipdb.com/api/v2/check?ipAddress=$ip&maxAgeInDays=90" \
                -H "Key: $abuse_key" -H "Accept: application/json" 2>/dev/null)
            if echo "$abuse_result" | jq -e '.data.abuseConfidenceScore' &>/dev/null; then
                local score reports
                score=$(echo "$abuse_result" | jq -r '.data.abuseConfidenceScore')
                reports=$(echo "$abuse_result" | jq -r '.data.totalReports')
                if [ "$score" -ge 50 ] 2>/dev/null; then
                    echo -e "  ${RED}[!] Abuse Score: $score% — $reports reports (HIGH RISK)${RESET}"
                elif [ "$score" -ge 10 ] 2>/dev/null; then
                    echo -e "  ${YELLOW}[!] Abuse Score: $score% — $reports reports (MODERATE)${RESET}"
                else
                    echo -e "  ${GREEN}[✓] Abuse Score: $score% — $reports reports (CLEAN)${RESET}"
                fi
            fi
        else
            echo -e "  ${DIM}  Add AbuseIPDB API key in Settings [16] for reputation data${RESET}"
            echo -e "  ${DIM}  Free key: https://www.abuseipdb.com/register${RESET}"
        fi

        # ASN reputation
        echo -e "\n${YELLOW}  ── ASN INFO ────────────────────────────────${RESET}"
        local asn
        asn=$(echo "$result" | jq -r '.as' | grep -oE 'AS[0-9]+' | head -1)
        if [ -n "$asn" ]; then
            local asn_info
            asn_info=$(curl -s --max-time 8 "https://api.bgpview.io/asn/${asn#AS}" 2>/dev/null)
            if echo "$asn_info" | jq -e '.data.name' &>/dev/null; then
                echo -e "  ${WHITE}ASN Name    :${RESET} $(echo "$asn_info" | jq -r '.data.name // "N/A"')"
                echo -e "  ${WHITE}Description :${RESET} $(echo "$asn_info" | jq -r '.data.description_short // "N/A"')"
                echo -e "  ${WHITE}Website     :${RESET} $(echo "$asn_info" | jq -r '.data.website // "N/A"')"
                local rir
                rir=$(echo "$asn_info" | jq -r '.data.rir_allocation.rir_name // "N/A"')
                echo -e "  ${WHITE}RIR         :${RESET} $rir"
            fi
        fi

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

    local target_domain
    target_domain=$(echo "$input_domain" | sed 's|https://||;s|http://||;s|/.*||' | tr -d '[:space:]')

    add_history "DOMAIN" "$target_domain"
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
    echo -e "${WHITE}  [A]${RESET}"; nslookup -type=A "$target_domain" 2>/dev/null | grep "Address:" | grep -v "#" | grep -v "127\." | head -5
    echo -e "${WHITE}  [MX]${RESET}"; nslookup -type=MX "$target_domain" 2>/dev/null | grep -i "mail\|exchanger" | head -5
    echo -e "${WHITE}  [TXT]${RESET}"; nslookup -type=TXT "$target_domain" 2>/dev/null | grep "text =" | head -5
    echo -e "${WHITE}  [NS]${RESET}"; nslookup -type=NS "$target_domain" 2>/dev/null | grep "nameserver\|name server" | head -5

    echo -e "\n${YELLOW}  ── IP & GEO ────────────────────────────────${RESET}"
    local domain_ip
    domain_ip=$(nslookup "$target_domain" 2>/dev/null | grep "Address:" | grep -v "#" | grep -v "127\." | tail -1 | awk '{print $2}')
    if [ -n "$domain_ip" ]; then
        echo -e "  ${WHITE}Resolved IP :${RESET} $domain_ip"
        local geo
        geo=$(curl -s --max-time 8 "http://ip-api.com/json/$domain_ip?fields=country,city,isp,org,as,proxy" 2>/dev/null)
        echo -e "  ${WHITE}Country     :${RESET} $(echo "$geo" | jq -r '.country')"
        echo -e "  ${WHITE}City        :${RESET} $(echo "$geo" | jq -r '.city')"
        echo -e "  ${WHITE}ISP         :${RESET} $(echo "$geo" | jq -r '.isp')"
        echo -e "  ${WHITE}Org         :${RESET} $(echo "$geo" | jq -r '.org')"
        echo -e "  ${WHITE}Proxy/VPN   :${RESET} $(echo "$geo" | jq -r '.proxy')"
    else
        echo -e "  ${RED}[!] Could not resolve domain to IP${RESET}"
    fi

    echo -e "\n${YELLOW}  ── SSL CERTIFICATE ─────────────────────────${RESET}"
    local ssl_info
    ssl_info=$(echo | timeout 8 openssl s_client -connect "$target_domain:443" \
        -servername "$target_domain" 2>/dev/null | openssl x509 -noout -dates -issuer -subject 2>/dev/null)
    if [ -n "$ssl_info" ]; then
        echo "$ssl_info"
        # Expiry countdown
        local expiry_date expiry_epoch now_epoch days_left
        expiry_date=$(echo "$ssl_info" | grep "notAfter" | cut -d'=' -f2)
        if [ -n "$expiry_date" ]; then
            expiry_epoch=$(python3 -c "from datetime import datetime; print(int(datetime.strptime('$expiry_date', '%b %d %H:%M:%S %Y %Z').timestamp()))" 2>/dev/null)
            now_epoch=$(date +%s)
            if [ -n "$expiry_epoch" ]; then
                days_left=$(( (expiry_epoch - now_epoch) / 86400 ))
                if [ "$days_left" -lt 30 ] 2>/dev/null; then
                    echo -e "  ${RED}  [!] Expires in $days_left days — CRITICAL${RESET}"
                elif [ "$days_left" -lt 90 ] 2>/dev/null; then
                    echo -e "  ${YELLOW}  [!] Expires in $days_left days — WARNING${RESET}"
                else
                    echo -e "  ${GREEN}  [✓] Expires in $days_left days — OK${RESET}"
                fi
            fi
        fi
    else
        echo -e "  ${DIM}  SSL info unavailable or HTTP only${RESET}"
    fi

    echo -e "\n${YELLOW}  ── HTTP REDIRECT CHECK ─────────────────────${RESET}"
    local http_status https_status
    http_status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 8 "http://$target_domain" 2>/dev/null)
    https_status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 8 "https://$target_domain" 2>/dev/null)
    echo -e "  ${WHITE}HTTP  :${RESET} $http_status"
    echo -e "  ${WHITE}HTTPS :${RESET} $https_status"
    if [[ "$http_status" == "301" || "$http_status" == "302" ]]; then
        echo -e "  ${GREEN}  [✓] HTTP redirects to HTTPS${RESET}"
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
    curl -sI "https://$target_domain" --max-time 8 -L -H "User-Agent: Mozilla/5.0" 2>/dev/null | \
        grep -iE "server|x-powered|content-type|strict-transport|x-frame|cf-ray|x-cache|via" | head -10

    echo -e "\n${YELLOW}  ── ROBOTS.TXT ──────────────────────────────${RESET}"
    local robots
    robots=$(curl -s "https://$target_domain/robots.txt" --max-time 8 -L 2>/dev/null)
    [ -n "$robots" ] && echo "$robots" | head -20 || echo -e "  ${DIM}  robots.txt not found${RESET}"

    log_result "domain" "$target_domain" "Domain recon completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 4: EMAIL OSINT
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

    add_history "EMAIL" "$email_input"

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
        echo -e "  ${RED}[✗] No MX records — domain may not accept email${RESET}"
    fi

    echo -e "\n${YELLOW}  ── GRAVATAR CHECK ──────────────────────────${RESET}"
    local md5hash
    md5hash=$(make_md5 "$email_input")
    if [ -n "$md5hash" ]; then
        local grav_status
        grav_status=$(curl -o /dev/null -s -w "%{http_code}" \
            "https://www.gravatar.com/avatar/${md5hash}?d=404" --max-time 8 2>/dev/null)
        if [ "$grav_status" == "200" ]; then
            echo -e "  ${GREEN}[✓] Gravatar profile found!${RESET}"
            echo -e "  ${WHITE}Avatar  :${RESET} https://www.gravatar.com/avatar/$md5hash"
            echo -e "  ${WHITE}Profile :${RESET} https://www.gravatar.com/$md5hash"
        else
            echo -e "  ${RED}[✗] No Gravatar profile${RESET}"
        fi
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
            -H "User-Agent: Mozilla/5.0" 2>/dev/null)
        [[ "$sc_status" == "200" ]] && echo -e "  ${GREEN}[✓]${RESET} ${social_names[$i]} → ${social_urls[$i]}"
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

    add_history "PHONE" "$phone"

    local country_code="Unknown"
    [[ "$phone" == +93*  ]] && country_code="Afghanistan 🇦🇫"
    [[ "$phone" == +355* ]] && country_code="Albania 🇦🇱"
    [[ "$phone" == +213* ]] && country_code="Algeria 🇩🇿"
    [[ "$phone" == +61*  ]] && country_code="Australia 🇦🇺"
    [[ "$phone" == +43*  ]] && country_code="Austria 🇦🇹"
    [[ "$phone" == +880* ]] && country_code="Bangladesh 🇧🇩"
    [[ "$phone" == +32*  ]] && country_code="Belgium 🇧🇪"
    [[ "$phone" == +55*  ]] && country_code="Brazil 🇧🇷"
    [[ "$phone" == +1*   ]] && country_code="USA / Canada 🇺🇸"
    [[ "$phone" == +86*  ]] && country_code="China 🇨🇳"
    [[ "$phone" == +57*  ]] && country_code="Colombia 🇨🇴"
    [[ "$phone" == +20*  ]] && country_code="Egypt 🇪🇬"
    [[ "$phone" == +251* ]] && country_code="Ethiopia 🇪🇹"
    [[ "$phone" == +33*  ]] && country_code="France 🇫🇷"
    [[ "$phone" == +49*  ]] && country_code="Germany 🇩🇪"
    [[ "$phone" == +233* ]] && country_code="Ghana 🇬🇭"
    [[ "$phone" == +30*  ]] && country_code="Greece 🇬🇷"
    [[ "$phone" == +91*  ]] && country_code="India 🇮🇳"
    [[ "$phone" == +62*  ]] && country_code="Indonesia 🇮🇩"
    [[ "$phone" == +98*  ]] && country_code="Iran 🇮🇷"
    [[ "$phone" == +964* ]] && country_code="Iraq 🇮🇶"
    [[ "$phone" == +353* ]] && country_code="Ireland 🇮🇪"
    [[ "$phone" == +972* ]] && country_code="Israel 🇮🇱"
    [[ "$phone" == +39*  ]] && country_code="Italy 🇮🇹"
    [[ "$phone" == +81*  ]] && country_code="Japan 🇯🇵"
    [[ "$phone" == +962* ]] && country_code="Jordan 🇯🇴"
    [[ "$phone" == +254* ]] && country_code="Kenya 🇰🇪"
    [[ "$phone" == +965* ]] && country_code="Kuwait 🇰🇼"
    [[ "$phone" == +961* ]] && country_code="Lebanon 🇱🇧"
    [[ "$phone" == +60*  ]] && country_code="Malaysia 🇲🇾"
    [[ "$phone" == +52*  ]] && country_code="Mexico 🇲🇽"
    [[ "$phone" == +212* ]] && country_code="Morocco 🇲🇦"
    [[ "$phone" == +95*  ]] && country_code="Myanmar 🇲🇲"
    [[ "$phone" == +31*  ]] && country_code="Netherlands 🇳🇱"
    [[ "$phone" == +64*  ]] && country_code="New Zealand 🇳🇿"
    [[ "$phone" == +234* ]] && country_code="Nigeria 🇳🇬"
    [[ "$phone" == +47*  ]] && country_code="Norway 🇳🇴"
    [[ "$phone" == +968* ]] && country_code="Oman 🇴🇲"
    [[ "$phone" == +92*  ]] && country_code="Pakistan 🇵🇰"
    [[ "$phone" == +63*  ]] && country_code="Philippines 🇵🇭"
    [[ "$phone" == +48*  ]] && country_code="Poland 🇵🇱"
    [[ "$phone" == +351* ]] && country_code="Portugal 🇵🇹"
    [[ "$phone" == +974* ]] && country_code="Qatar 🇶🇦"
    [[ "$phone" == +7*   ]] && country_code="Russia 🇷🇺"
    [[ "$phone" == +966* ]] && country_code="Saudi Arabia 🇸🇦"
    [[ "$phone" == +65*  ]] && country_code="Singapore 🇸🇬"
    [[ "$phone" == +27*  ]] && country_code="South Africa 🇿🇦"
    [[ "$phone" == +82*  ]] && country_code="South Korea 🇰🇷"
    [[ "$phone" == +34*  ]] && country_code="Spain 🇪🇸"
    [[ "$phone" == +94*  ]] && country_code="Sri Lanka 🇱🇰"
    [[ "$phone" == +46*  ]] && country_code="Sweden 🇸🇪"
    [[ "$phone" == +41*  ]] && country_code="Switzerland 🇨🇭"
    [[ "$phone" == +886* ]] && country_code="Taiwan 🇹🇼"
    [[ "$phone" == +255* ]] && country_code="Tanzania 🇹🇿"
    [[ "$phone" == +66*  ]] && country_code="Thailand 🇹🇭"
    [[ "$phone" == +216* ]] && country_code="Tunisia 🇹🇳"
    [[ "$phone" == +90*  ]] && country_code="Turkey 🇹🇷"
    [[ "$phone" == +256* ]] && country_code="Uganda 🇺🇬"
    [[ "$phone" == +380* ]] && country_code="Ukraine 🇺🇦"
    [[ "$phone" == +971* ]] && country_code="UAE 🇦🇪"
    [[ "$phone" == +44*  ]] && country_code="United Kingdom 🇬🇧"
    [[ "$phone" == +84*  ]] && country_code="Vietnam 🇻🇳"
    [[ "$phone" == +967* ]] && country_code="Yemen 🇾🇪"
    [[ "$phone" == +263* ]] && country_code="Zimbabwe 🇿🇼"

    local clean_phone wa_number
    clean_phone=$(echo "$phone" | tr -d '+- ()')
    wa_number=$(echo "$phone" | tr -d '+')

    # E.164 format
    local e164="+$wa_number"

    echo -e "${YELLOW}  ── NUMBER INFO ─────────────────────────────${RESET}"
    echo -e "  ${WHITE}Number   :${RESET} $phone"
    echo -e "  ${WHITE}E.164    :${RESET} $e164"
    echo -e "  ${WHITE}Country  :${RESET} $country_code"
    echo -e "  ${WHITE}Digits   :${RESET} ${#clean_phone}"

    echo -e "\n${YELLOW}  ── PUBLIC LOOKUP LINKS ─────────────────────${RESET}"
    echo -e "  ${WHITE}Truecaller  :${RESET} https://www.truecaller.com/search/in/$clean_phone"
    echo -e "  ${WHITE}Sync.me     :${RESET} https://sync.me/search/?number=$phone"
    echo -e "  ${WHITE}SpamCalls   :${RESET} https://www.shouldianswer.com/phone-number/$clean_phone"
    echo -e "  ${WHITE}Numverify   :${RESET} https://numverify.com/phone-number-validate?number=$clean_phone"

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
# ─────────────────────────────────────────
network_osint() {
    banner
    section "NETWORK OSINT"
    echo -e "${CYAN}  [*] Gathering network info...\n${RESET}"

    local pub_ip
    pub_ip=$(curl -s --max-time 8 https://api.ipify.org 2>/dev/null | tr -d '[:space:]')
    [ -z "$pub_ip" ] && pub_ip=$(curl -s --max-time 8 https://ifconfig.me 2>/dev/null | tr -d '[:space:]')
    if [ -z "$pub_ip" ]; then
        echo -e "${RED}  [!] Could not fetch public IP.${RESET}"
        press_enter; return
    fi

    echo -e "${YELLOW}  ── PUBLIC IP ───────────────────────────────${RESET}"
    echo -e "  ${WHITE}IP :${RESET} $pub_ip"

    echo -e "\n${YELLOW}  ── GEOLOCATION ─────────────────────────────${RESET}"
    local geo
    geo=$(curl -s --max-time 10 "http://ip-api.com/json/$pub_ip?fields=country,city,isp,org,as,timezone,proxy" 2>/dev/null)
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
        [ "$pub_ip" == "$dns_ip" ] && \
            echo -e "  ${GREEN}[✓] No DNS leak detected${RESET}" || \
            echo -e "  ${YELLOW}[!] Possible DNS leak — IPs differ${RESET}"
    else
        echo -e "  ${DIM}  DNS leak check unavailable${RESET}"
    fi

    echo -e "\n${YELLOW}  ── SPEED TEST ──────────────────────────────${RESET}"
    echo -e "  ${CYAN}Testing...${RESET}"
    local speed
    speed=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 12 \
        "http://speedtest.ftp.otenet.gr/files/test1Mb.db" 2>/dev/null)
    [ -z "$speed" ] || [ "$speed" == "0" ] && \
        speed=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 12 \
        "http://proof.ovh.net/files/1Mb.dat" 2>/dev/null)
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
# ─────────────────────────────────────────
google_dork() {
    banner
    section "GOOGLE DORKING HELPER"
    echo -e "${DIM}  Auto-generates Google dork queries for OSINT${RESET}\n"
    echo -ne "${GREEN}  [?] Enter target (domain, name, or keyword): ${RESET}"
    read -r dork_target

    [ -z "$dork_target" ] && press_enter && return

    add_history "DORK" "$dork_target"

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

    echo -e "\n${YELLOW}  ── GENERATED DORKS ─────────────────────────${RESET}\n"
    local report_content=""
    for dork in "${dorks[@]}"; do
        local encoded
        encoded=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$dork" 2>/dev/null)
        echo -e "  ${GREEN}►${RESET} ${WHITE}$dork${RESET}"
        [ -n "$encoded" ] && echo -e "    ${DIM}https://www.google.com/search?q=$encoded${RESET}\n"
        report_content+="$dork\nhttps://www.google.com/search?q=$encoded\n\n"
    done

    save_report "dorks_${dork_target}" "$report_content"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 8: WEBSITE FINGERPRINT
# ─────────────────────────────────────────
tech_fingerprint() {
    banner
    section "WEBSITE TECH FINGERPRINT"
    echo -ne "${GREEN}  [?] Enter URL or domain: ${RESET}"
    read -r fp_url

    [ -z "$fp_url" ] && press_enter && return
    [[ "$fp_url" != http* ]] && fp_url="https://$fp_url"

    add_history "FINGERPRINT" "$fp_url"
    echo -e "\n${CYAN}  [*] Fingerprinting: ${WHITE}$fp_url${RESET}\n"

    local fp_headers fp_body fp_domain
    fp_domain=$(echo "$fp_url" | sed 's|https://||;s|http://||;s|/.*||')
    fp_headers=$(curl -sI "$fp_url" --max-time 10 -L -H "User-Agent: Mozilla/5.0" 2>/dev/null)
    fp_body=$(curl -sL "$fp_url" --max-time 10 -H "User-Agent: Mozilla/5.0" 2>/dev/null)

    echo -e "${YELLOW}  ── HTTP HEADERS ────────────────────────────${RESET}"
    if [ -n "$fp_headers" ]; then
        echo "$fp_headers" | grep -iE "server|x-powered|x-generator|cf-ray|x-cache|x-drupal|x-wordpress|via|content-type|strict-transport|access-control|x-runtime"
    else
        echo -e "  ${RED}[!] No response${RESET}"; press_enter; return
    fi

    echo -e "\n${YELLOW}  ── CMS & TECHNOLOGY ────────────────────────${RESET}"
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
    fp_check "Platform: Squarespace" "squarespace"
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
    local ssl_info
    ssl_info=$(echo | timeout 8 openssl s_client -connect "$fp_domain:443" \
        -servername "$fp_domain" 2>/dev/null | openssl x509 -noout -dates -issuer -subject 2>/dev/null)
    [ -n "$ssl_info" ] && echo "$ssl_info" || echo -e "  ${DIM}  SSL unavailable${RESET}"

    press_enter
}

# ─────────────────────────────────────────
# MODULE 9: WAYBACK MACHINE
# ─────────────────────────────────────────
wayback_lookup() {
    banner
    section "WAYBACK MACHINE LOOKUP"
    echo -ne "${GREEN}  [?] Enter domain (e.g. example.com): ${RESET}"
    read -r wb_target

    [ -z "$wb_target" ] && press_enter && return

    wb_target=$(echo "$wb_target" | sed 's|https://||;s|http://||;s|/.*||' | tr -d '[:space:]')
    add_history "WAYBACK" "$wb_target"

    echo -e "\n${CYAN}  [*] Searching Wayback Machine for: ${WHITE}$wb_target${RESET}\n"

    local avail snap_url snap_time snap_status
    snap_url=""
    avail=$(curl -s --max-time 10 "https://archive.org/wayback/available?url=$wb_target" 2>/dev/null)

    echo -e "${YELLOW}  ── AVAILABILITY CHECK ──────────────────────${RESET}"
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

    echo -e "\n${YELLOW}  ── HISTORY LINKS ───────────────────────────${RESET}"
    echo -e "  ${WHITE}All snapshots :${RESET} https://web.archive.org/web/*/$wb_target"
    for year in 2022 2020 2018 2015; do
        echo -e "  ${WHITE}Year $year      :${RESET} https://web.archive.org/web/${year}*/$wb_target"
    done

    echo -e "\n${YELLOW}  ── TOTAL CRAWL COUNT ───────────────────────${RESET}"
    local cdx
    cdx=$(curl -s --max-time 10 \
        "https://web.archive.org/cdx/search/cdx?url=$wb_target&output=json&showNumPages=true" 2>/dev/null)
    echo "$cdx" | grep -qE '^[0-9]+$' && \
        echo -e "  ${WHITE}Total archived pages :${RESET} $cdx" || \
        echo -e "  ${DIM}  Count unavailable${RESET}"

    local report_content="Wayback lookup for: $wb_target\n"
    [ -n "$snap_url" ] && report_content+="Latest snapshot: $snap_url\n"
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
    echo -ne "${GREEN}  [?] Enter GitHub username or org: ${RESET}"
    read -r ghuser

    [ -z "$ghuser" ] && press_enter && return

    add_history "GITHUB" "$ghuser"
    echo -e "\n${CYAN}  [*] Fetching GitHub data for: ${WHITE}$ghuser${RESET}\n"

    local profile
    profile=$(curl -s --max-time 10 "https://api.github.com/users/$ghuser" \
        -H "Accept: application/vnd.github.v3+json" 2>/dev/null)

    echo -e "${YELLOW}  ── PROFILE ─────────────────────────────────${RESET}"
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
        echo -e "  ${RED}[!] $(echo "$profile" | jq -r '.message // "User not found"')${RESET}"
        press_enter; return
    fi

    echo -e "\n${YELLOW}  ── REPOSITORIES (latest 10) ────────────────${RESET}"
    local repos_data
    repos_data=$(curl -s --max-time 10 \
        "https://api.github.com/users/$ghuser/repos?sort=updated&per_page=10" \
        -H "Accept: application/vnd.github.v3+json" 2>/dev/null)
    echo "$repos_data" | jq -e '.[0]' &>/dev/null && \
        echo "$repos_data" | jq -r '.[] | "  ► \(.name) [\(.language // "N/A")] ⭐\(.stargazers_count) — \(.description // "No description")"' | head -10 || \
        echo -e "  ${DIM}  No public repos${RESET}"

    echo -e "\n${YELLOW}  ── ORGANIZATIONS ───────────────────────────${RESET}"
    local orgs
    orgs=$(curl -s --max-time 8 "https://api.github.com/users/$ghuser/orgs" \
        -H "Accept: application/vnd.github.v3+json" 2>/dev/null)
    echo "$orgs" | jq -e '.[0]' &>/dev/null && \
        echo "$orgs" | jq -r '.[].login' | while read -r org; do echo -e "  ${GREEN}[✓]${RESET} $org"; done || \
        echo -e "  ${DIM}  No public organizations${RESET}"

    echo -e "\n${YELLOW}  ── GISTS ───────────────────────────────────${RESET}"
    local gists
    gists=$(curl -s --max-time 8 "https://api.github.com/users/$ghuser/gists?per_page=5" \
        -H "Accept: application/vnd.github.v3+json" 2>/dev/null)
    echo "$gists" | jq -e '.[0]' &>/dev/null && \
        echo "$gists" | jq -r '.[] | "  ► \(.description // "No description") — \(.html_url)"' | head -5 || \
        echo -e "  ${DIM}  No public gists${RESET}"

    echo -e "\n  ${WHITE}GitHub :${RESET} https://github.com/$ghuser"
    save_report "github_${ghuser}" "$(echo "$profile" | jq .)"
    log_result "github" "$ghuser" "GitHub OSINT completed"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 11: SHODAN LOOKUP
# ─────────────────────────────────────────
shodan_lookup() {
    banner
    section "SHODAN LOOKUP"

    local shodan_key=""
    [ -f "$CONFIG_FILE" ] && shodan_key=$(grep "^SHODAN_API=" "$CONFIG_FILE" 2>/dev/null | tail -1 | cut -d'=' -f2-)

    if [ -z "$shodan_key" ]; then
        echo -e "${YELLOW}  [!] No Shodan API key saved.${RESET}"
        echo -e "${DIM}  Free key at: ${WHITE}https://account.shodan.io/register${RESET}\n"
        echo -ne "${GREEN}  [?] Enter your Shodan API key (or press Enter to skip): ${RESET}"
        read -r input_key

        if [ -z "$input_key" ]; then
            echo -e "\n${CYAN}  Sign up and come back with your key.${RESET}"
            press_enter; return
        fi

        echo -e "\n${CYAN}  [*] Verifying...${RESET}"
        local verify
        verify=$(curl -s --max-time 10 "https://api.shodan.io/api-info?key=$input_key" 2>/dev/null)

        if echo "$verify" | jq -e '.query_credits' &>/dev/null; then
            echo -e "  ${GREEN}[✓] Valid — Credits: $(echo "$verify" | jq -r '.query_credits')${RESET}"
            [ -f "$CONFIG_FILE" ] && grep -v "^SHODAN_API=" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
            echo "SHODAN_API=$input_key" >> "$CONFIG_FILE"
            shodan_key="$input_key"
        else
            echo -e "  ${RED}[!] $(echo "$verify" | jq -r '.error // "Invalid key"')${RESET}"
            press_enter; return
        fi
    else
        echo -e "  ${GREEN}[✓] Saved API key loaded${RESET}"
    fi

    echo ""
    echo -ne "${GREEN}  [?] Enter IP to look up: ${RESET}"
    read -r sh_ip

    [ -z "$sh_ip" ] && press_enter && return

    if ! echo "$sh_ip" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
        echo -e "${RED}  [!] Invalid IP format.${RESET}"; press_enter; return
    fi

    add_history "SHODAN" "$sh_ip"
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
        [ -n "$sh_ports" ] && echo "$sh_ports" | while read -r p; do echo -e "  ${GREEN}[OPEN]${RESET} Port $p"; done || echo -e "  ${DIM}  No port data${RESET}"

        echo -e "\n${YELLOW}  ── HOSTNAMES ───────────────────────────────${RESET}"
        local sh_hosts
        sh_hosts=$(echo "$sh_result" | jq -r '.hostnames[]?' 2>/dev/null)
        [ -n "$sh_hosts" ] && echo "$sh_hosts" | while read -r h; do echo -e "  ${WHITE}►${RESET} $h"; done || echo -e "  ${DIM}  No hostnames${RESET}"

        echo -e "\n${YELLOW}  ── VULNERABILITIES ─────────────────────────${RESET}"
        local sh_vulns
        sh_vulns=$(echo "$sh_result" | jq -r '.vulns | keys[]?' 2>/dev/null)
        [ -n "$sh_vulns" ] && echo "$sh_vulns" | while read -r v; do echo -e "  ${RED}[CVE]${RESET} $v"; done || echo -e "  ${GREEN}  No known CVEs${RESET}"

        echo -e "\n${YELLOW}  ── SERVICE BANNERS ─────────────────────────${RESET}"
        echo "$sh_result" | jq -r '.data[]? | "  Port \(.port)/\(.transport // "tcp") — \(.product // "unknown") \(.version // "")"' 2>/dev/null | head -5

        save_report "shodan_${sh_ip}" "$(echo "$sh_result" | jq .)"
        log_result "shodan" "$sh_ip" "Shodan lookup completed"
    else
        local sh_err
        sh_err=$(echo "$sh_result" | jq -r '.error // "No data found"')
        echo -e "  ${RED}[!] $sh_err${RESET}"
        echo "$sh_err" | grep -qi "credit\|limit\|quota" && \
            echo -e "  ${YELLOW}  Query credits exhausted.${RESET}"
    fi
    press_enter
}

# ─────────────────────────────────────────
# MODULE 12: DNS BRUTE FORCE
# ─────────────────────────────────────────
dns_brute() {
    banner
    section "DNS BRUTE FORCE"
    echo -ne "${GREEN}  [?] Enter target domain (e.g. example.com): ${RESET}"
    read -r dns_domain

    [ -z "$dns_domain" ] && press_enter && return

    dns_domain=$(echo "$dns_domain" | sed 's|https://||;s|http://||;s|/.*||' | tr -d '[:space:]')
    add_history "DNS_BRUTE" "$dns_domain"

    local wordlist=(
        "www" "mail" "ftp" "admin" "webmail" "portal" "api" "dev" "staging" "blog"
        "shop" "vpn" "remote" "app" "cpanel" "smtp" "pop" "imap" "cdn" "static"
        "test" "beta" "alpha" "demo" "old" "new" "secure" "login" "auth" "sso"
        "dashboard" "panel" "manage" "management" "cloud" "media" "assets" "files"
        "docs" "support" "help" "kb" "wiki" "forum" "community" "chat" "video"
        "images" "img" "js" "css" "download" "uploads" "backup" "db" "database"
        "mysql" "phpmyadmin" "pma" "server" "host" "ns1" "ns2" "mx" "mx1" "mx2"
        "relay" "gateway" "proxy" "cache" "monitor" "status" "health" "metrics"
        "git" "gitlab" "github" "ci" "jenkins" "build" "deploy" "stage" "prod"
        "mobile" "m" "wap" "android" "ios" "app1" "app2" "web" "web1" "web2"
        "intranet" "internal" "private" "corp" "office" "vpn2" "ssl" "www2" "www3"
        "store" "pay" "payment" "checkout" "cart" "order" "invoice" "billing"
        "report" "reports" "analytics" "stats" "tracking" "trace" "log" "logs"
        "api2" "api-v2" "v1" "v2" "graphql" "rest" "soap" "ws" "socket"
    )

    local total=${#wordlist[@]}
    echo -e "\n${CYAN}  [*] Brute forcing ${WHITE}$total${CYAN} subdomains on ${WHITE}$dns_domain${CYAN}...${RESET}\n"

    local found_count=0
    local results_dir="$TEMP_DIR/dns_$$"
    mkdir -p "$results_dir"
    local report_content=""

    # Parallel DNS brute — use C-style loop so idx is in parent scope
    for (( idx=0; idx<total; idx++ )); do
        local sub="${wordlist[$idx]}"
        (
            local resolved
            resolved=$(nslookup "$sub.$dns_domain" 2>/dev/null | grep "Address:" | grep -v "#" | grep -v "127\." | tail -1 | awk '{print $2}')
            if [ -n "$resolved" ]; then
                echo "$sub.$dns_domain|$resolved" > "$results_dir/$idx"
            else
                touch "$results_dir/done_$idx"
            fi
        ) &
    done

    # Progress while waiting — count both result files and done markers
    local completed=0
    while [ $completed -lt $total ]; do
        completed=$(ls "$results_dir" 2>/dev/null | wc -l)
        show_progress "$completed" "$total" "brute forcing"
        sleep 0.4
    done
    wait
    printf "\n\n"

    # Display results — skip done_ marker files, only read actual result files
    for result_file in "$results_dir"/*; do
        [ -f "$result_file" ] || continue
        # Skip marker files that have no pipe-delimited content
        local fname
        fname=$(basename "$result_file")
        [[ "$fname" == done_* ]] && continue
        local line
        line=$(cat "$result_file")
        # Only process lines that contain a pipe separator
        [[ "$line" != *"|"* ]] && continue
        local subdomain="${line%%|*}"
        local ip="${line#*|}"
        [ -z "$subdomain" ] || [ -z "$ip" ] && continue
        echo -e "  ${GREEN}[✓]${RESET} $subdomain ${WHITE}→${RESET} $ip"
        report_content+="[FOUND] $subdomain → $ip\n"
        ((found_count++))
    done

    rm -rf "$results_dir"

    echo -e "\n${YELLOW}  ─────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}Found: $found_count subdomains out of $total checked${RESET}"

    [ $found_count -eq 0 ] && echo -e "  ${DIM}  No subdomains found${RESET}"

    save_report "dns_brute_${dns_domain}" "$report_content"
    log_result "dns_brute" "$dns_domain" "$report_content"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 13: HASH IDENTIFIER & LOOKUP
# ─────────────────────────────────────────
hash_lookup() {
    banner
    section "HASH IDENTIFIER & LOOKUP"
    echo -ne "${GREEN}  [?] Enter hash to identify: ${RESET}"
    read -r hash_input

    [ -z "$hash_input" ] && press_enter && return

    hash_input=$(echo "$hash_input" | tr -d '[:space:]')
    add_history "HASH" "$hash_input"

    local hash_len=${#hash_input}
    local hash_type="Unknown"

    echo -e "\n${CYAN}  [*] Analyzing hash: ${WHITE}$hash_input${RESET}\n"

    echo -e "${YELLOW}  ── IDENTIFICATION ──────────────────────────${RESET}"
    echo -e "  ${WHITE}Length   :${RESET} $hash_len characters"

    # Identify hash type by length and pattern
    if echo "$hash_input" | grep -qE '^[a-fA-F0-9]+$'; then
        case $hash_len in
            32)  hash_type="MD5" ;;
            40)  hash_type="SHA-1" ;;
            56)  hash_type="SHA-224" ;;
            64)  hash_type="SHA-256" ;;
            96)  hash_type="SHA-384" ;;
            128) hash_type="SHA-512" ;;
            16)  hash_type="MySQL v3 / DES (partial)" ;;
            *)   hash_type="Unknown hex hash ($hash_len chars)" ;;
        esac
    elif echo "$hash_input" | grep -qE '^\$2[ayb]\$'; then
        hash_type="bcrypt"
    elif echo "$hash_input" | grep -qE '^\$1\$'; then
        hash_type="MD5 Crypt (Linux)"
    elif echo "$hash_input" | grep -qE '^\$5\$'; then
        hash_type="SHA-256 Crypt (Linux)"
    elif echo "$hash_input" | grep -qE '^\$6\$'; then
        hash_type="SHA-512 Crypt (Linux)"
    elif echo "$hash_input" | grep -qE '^\$apr1\$'; then
        hash_type="MD5 APR (Apache)"
    elif echo "$hash_input" | grep -qE '^[a-zA-Z0-9+/]{22}==?$'; then
        hash_type="Possibly Base64 encoded"
    fi

    echo -e "  ${WHITE}Hash Type:${RESET} ${GREEN}$hash_type${RESET}"

    # Only attempt lookup for crackable types
    if [[ "$hash_type" == "MD5" || "$hash_type" == "SHA-1" || "$hash_type" == "SHA-256" ]]; then
        echo -e "\n${YELLOW}  ── ONLINE LOOKUP ───────────────────────────${RESET}"
        echo -e "  ${CYAN}  Checking hash databases...${RESET}"

        # md5decrypt.net — response is plain text, "Not found" or the plaintext
        local lookup_result
        lookup_result=$(curl -s --max-time 10 \
            "https://md5decrypt.net/Api/api.php?hash=$hash_input&hash_type=md5&email=guest@guest.com&code=api_pub" \
            2>/dev/null | tr -d '[:space:]')

        if [ -n "$lookup_result" ] && \
           [ "$lookup_result" != "Notfound" ] && \
           [ "$lookup_result" != "0" ] && \
           [ ${#lookup_result} -lt 100 ]; then
            echo -e "  ${GREEN}[✓] Hash cracked!${RESET}"
            echo -e "  ${WHITE}Plaintext :${RESET} $lookup_result"
        else
            echo -e "  ${RED}[✗] Not found in md5decrypt.net${RESET}"
        fi

        # nitrxgen — only for MD5
        if [ "$hash_type" == "MD5" ]; then
            local nitr
            nitr=$(curl -s --max-time 10 "https://www.nitrxgen.net/md5db/$hash_input" 2>/dev/null | tr -d '[:space:]')
            if [ -n "$nitr" ] && [ ${#nitr} -lt 100 ]; then
                echo -e "  ${GREEN}[✓] Found on nitrxgen: ${WHITE}$nitr${RESET}"
            else
                echo -e "  ${RED}[✗] Not found on nitrxgen${RESET}"
            fi
        fi

        echo -e "\n${YELLOW}  ── MANUAL LOOKUP LINKS ─────────────────────${RESET}"
        echo -e "  ${WHITE}CrackStation :${RESET} https://crackstation.net"
        echo -e "  ${WHITE}HashKiller    :${RESET} https://hashkiller.io/listmanager"
        echo -e "  ${WHITE}md5decrypt    :${RESET} https://md5decrypt.net"
    else
        echo -e "\n${YELLOW}  ── LOOKUP LINKS ────────────────────────────${RESET}"
        echo -e "  ${DIM}  Online lookup only supports MD5/SHA1/SHA256${RESET}"
        echo -e "  ${WHITE}CrackStation :${RESET} https://crackstation.net"
    fi

    echo -e "\n${YELLOW}  ── GENERATE HASHES (for comparison) ───────${RESET}"
    echo -ne "${GREEN}  [?] Enter text to hash (or press Enter to skip): ${RESET}"
    read -r hash_text
    if [ -n "$hash_text" ]; then
        local md5 sha1 sha256
        md5=$(python3 -c "import hashlib,sys; print(hashlib.md5(sys.argv[1].encode()).hexdigest())" "$hash_text" 2>/dev/null)
        sha1=$(python3 -c "import hashlib,sys; print(hashlib.sha1(sys.argv[1].encode()).hexdigest())" "$hash_text" 2>/dev/null)
        sha256=$(python3 -c "import hashlib,sys; print(hashlib.sha256(sys.argv[1].encode()).hexdigest())" "$hash_text" 2>/dev/null)
        echo -e "  ${WHITE}MD5    :${RESET} $md5"
        echo -e "  ${WHITE}SHA-1  :${RESET} $sha1"
        echo -e "  ${WHITE}SHA-256:${RESET} $sha256"
        if [ "$md5" == "$hash_input" ] || [ "$sha1" == "$hash_input" ] || [ "$sha256" == "$hash_input" ]; then
            echo -e "\n  ${GREEN}[✓] Hash matches the input text!${RESET}"
        fi
    fi

    press_enter
}

# ─────────────────────────────────────────
# MODULE 14: MAC ADDRESS LOOKUP
# ─────────────────────────────────────────
mac_lookup() {
    banner
    section "MAC ADDRESS LOOKUP"
    echo -ne "${GREEN}  [?] Enter MAC address (e.g. 00:1A:2B:3C:4D:5E): ${RESET}"
    read -r mac_input

    [ -z "$mac_input" ] && press_enter && return

    # Normalize MAC — accept colons, dashes, dots, no separator
    local mac_clean
    mac_clean=$(echo "$mac_input" | tr '[:lower:]' '[:upper:]' | tr -d ':-.' | sed 's/\(..\)/\1:/g;s/:$//')

    if ! echo "$mac_clean" | grep -qE '^([0-9A-F]{2}:){5}[0-9A-F]{2}$'; then
        echo -e "${RED}  [!] Invalid MAC format. Example: 00:1A:2B:3C:4D:5E${RESET}"
        press_enter; return
    fi

    add_history "MAC" "$mac_clean"

    local oui="${mac_clean:0:8}"
    echo -e "\n${CYAN}  [*] Looking up: ${WHITE}$mac_clean${RESET}\n"

    echo -e "${YELLOW}  ── MAC INFO ────────────────────────────────${RESET}"
    echo -e "  ${WHITE}MAC Address :${RESET} $mac_clean"
    echo -e "  ${WHITE}OUI         :${RESET} $oui"
    local first_octet first_octet_dec
    first_octet=$(echo "$mac_clean" | cut -d':' -f1)
    first_octet_dec=$(python3 -c "print(int('$first_octet', 16))" 2>/dev/null)
    if [ -n "$first_octet_dec" ] && [ "$first_octet_dec" -eq "$first_octet_dec" ] 2>/dev/null; then
        if [ $(( first_octet_dec & 1 )) -eq 1 ]; then
            echo -e "  ${YELLOW}  [!] Multicast/Broadcast address${RESET}"
        fi
        if [ $(( first_octet_dec & 2 )) -eq 2 ]; then
            echo -e "  ${YELLOW}  [!] Locally administered (not a real OUI)${RESET}"
        fi
    fi

    echo -e "\n${YELLOW}  ── VENDOR LOOKUP ───────────────────────────${RESET}"
    local vendor_result
    vendor_result=$(curl -s --max-time 10 \
        "https://api.macvendors.com/$oui" 2>/dev/null)

    if [ -n "$vendor_result" ] && ! echo "$vendor_result" | grep -qi "error\|not found\|Too Many"; then
        echo -e "  ${GREEN}[✓] Vendor found!${RESET}"
        echo -e "  ${WHITE}Manufacturer :${RESET} $vendor_result"
    else
        echo -e "  ${RED}[✗] Vendor not found in database${RESET}"
    fi

    # Second source — macvendorlookup returns JSON array
    local vendor2
    vendor2=$(curl -s --max-time 10 \
        "https://www.macvendorlookup.com/api/v2/$oui" 2>/dev/null | \
        jq -r '.[0].company // empty' 2>/dev/null)
    if [ -n "$vendor2" ] && [ "$vendor2" != "null" ] && [ "$vendor2" != "empty" ]; then
        echo -e "  ${WHITE}Second source:${RESET} $vendor2"
    fi

    echo -e "\n${YELLOW}  ── ADDITIONAL INFO ─────────────────────────${RESET}"
    echo -e "  ${WHITE}Lookup URL   :${RESET} https://macvendors.com/query/$oui"
    echo -e "  ${WHITE}IEEE OUI DB  :${RESET} https://regauth.standards.ieee.org/standards-ra-web/pub/view.html"

    press_enter
}

# ─────────────────────────────────────────
# MODULE 15: URL EXPANDER / UNSHORTENER
# ─────────────────────────────────────────
url_expander() {
    banner
    section "URL EXPANDER / UNSHORTENER"
    echo -e "${DIM}  Expands short URLs — bit.ly, tinyurl, t.co, etc.${RESET}\n"
    echo -ne "${GREEN}  [?] Enter short URL: ${RESET}"
    read -r short_url

    [ -z "$short_url" ] && press_enter && return
    [[ "$short_url" != http* ]] && short_url="https://$short_url"

    add_history "URL_EXPAND" "$short_url"
    echo -e "\n${CYAN}  [*] Expanding: ${WHITE}$short_url${RESET}\n"

    echo -e "${YELLOW}  ── REDIRECT CHAIN ──────────────────────────${RESET}"
    local final_url
    final_url=$(curl -s --max-time 15 -o /dev/null -w "%{url_effective}" -L "$short_url" \
        -H "User-Agent: Mozilla/5.0" 2>/dev/null)

    local redirect_chain
    redirect_chain=$(curl -s --max-time 15 -v -o /dev/null -L "$short_url" \
        -H "User-Agent: Mozilla/5.0" 2>&1 | grep "< Location:" | sed 's/< Location: /  → /')

    if [ -n "$redirect_chain" ]; then
        echo "$redirect_chain"
    fi

    echo -e "\n${YELLOW}  ── FINAL URL ───────────────────────────────${RESET}"
    if [ -n "$final_url" ] && [ "$final_url" != "$short_url" ]; then
        echo -e "  ${GREEN}[✓] Resolved!${RESET}"
        echo -e "  ${WHITE}Final URL :${RESET} $final_url"

        # Extract domain
        local final_domain
        final_domain=$(echo "$final_url" | sed 's|https://||;s|http://||;s|/.*||')
        echo -e "  ${WHITE}Domain    :${RESET} $final_domain"

        # Check if suspicious
        local suspicious_tlds=("xyz" "top" "tk" "ml" "ga" "cf" "gq" "pw" "cc" "ru")
        local tld="${final_domain##*.}"
        for s in "${suspicious_tlds[@]}"; do
            if [ "$tld" == "$s" ]; then
                echo -e "  ${RED}  [!] Warning: .${tld} TLD is commonly used in phishing${RESET}"
                break
            fi
        done

        # IP of final domain
        local final_ip
        final_ip=$(nslookup "$final_domain" 2>/dev/null | grep "Address:" | grep -v "#" | grep -v "127\." | tail -1 | awk '{print $2}')
        [ -n "$final_ip" ] && echo -e "  ${WHITE}IP        :${RESET} $final_ip"
    else
        echo -e "  ${RED}[✗] Could not resolve — URL may already be the final destination${RESET}"
        echo -e "  ${WHITE}URL       :${RESET} $final_url"
    fi

    echo -e "\n${YELLOW}  ── SAFETY CHECK LINKS ──────────────────────${RESET}"
    if [ -n "$final_url" ]; then
        local encoded_url
        encoded_url=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$final_url" 2>/dev/null)
        local final_domain
        final_domain=$(echo "$final_url" | sed 's|https://||;s|http://||;s|/.*||')
        echo -e "  ${WHITE}VirusTotal :${RESET} https://www.virustotal.com/gui/url/$encoded_url"
        echo -e "  ${WHITE}URLScan    :${RESET} https://urlscan.io/search/#page.url:\"$final_domain\""
    else
        echo -e "  ${DIM}  Safety links unavailable — could not resolve URL${RESET}"
    fi

    press_enter
}

# ─────────────────────────────────────────
# MODULE 16: BANNER GRABBER
# ─────────────────────────────────────────
banner_grabber() {
    banner
    section "BANNER GRABBER"
    echo -ne "${GREEN}  [?] Enter target IP or domain: ${RESET}"
    read -r bg_host

    [ -z "$bg_host" ] && press_enter && return

    bg_host=$(echo "$bg_host" | sed 's|https://||;s|http://||;s|/.*||' | tr -d '[:space:]')
    add_history "BANNER" "$bg_host"

    echo -e "\n${CYAN}  [*] Grabbing banners from: ${WHITE}$bg_host${RESET}\n"

    local common_ports=(21 22 23 25 53 80 110 143 443 445 993 995 3306 5432 6379 8080 8443 8888 27017)

    echo -e "${YELLOW}  ── PORT & BANNER SCAN ──────────────────────${RESET}"

    for port in "${common_ports[@]}"; do
        # Check if port is open
        if timeout 2 bash -c "echo >/dev/tcp/$bg_host/$port" 2>/dev/null; then
            local bg_banner=""

            # Grab banner — use curl for HTTP ports, openssl for HTTPS, raw tcp for others
            case $port in
                80)
                    bg_banner=$(curl -sI "http://$bg_host" --max-time 5 2>/dev/null | \
                        grep -iE "server|x-powered" | head -2) ;;
                443)
                    bg_banner=$(echo | timeout 5 openssl s_client \
                        -connect "$bg_host:443" -servername "$bg_host" 2>/dev/null | \
                        openssl x509 -noout -subject -issuer 2>/dev/null | head -2) ;;
                8080|8443|8888)
                    bg_banner=$(curl -sI "http://$bg_host:$port" --max-time 5 2>/dev/null | \
                        grep -iE "server|x-powered" | head -2) ;;
                22)
                    # SSH banner is sent immediately on connect
                    bg_banner=$(timeout 3 bash -c \
                        "exec 3<>/dev/tcp/$bg_host/22; read -r line <&3; echo \$line" 2>/dev/null | \
                        head -1) ;;
                21|25|110|143)
                    # FTP/SMTP/POP3/IMAP send banner on connect
                    bg_banner=$(timeout 3 bash -c \
                        "exec 3<>/dev/tcp/$bg_host/$port; read -r line <&3; echo \$line" 2>/dev/null | \
                        head -1) ;;
                3306)
                    # MySQL — grab raw bytes, extract printable chars
                    bg_banner=$(timeout 3 bash -c \
                        "exec 3<>/dev/tcp/$bg_host/3306; read -r line <&3; echo \$line" 2>/dev/null | \
                        tr -cd '[:print:]' | head -c 80) ;;
                *)
                    bg_banner=$(timeout 3 bash -c \
                        "exec 3<>/dev/tcp/$bg_host/$port; read -r line <&3; echo \$line" 2>/dev/null | \
                        head -1) ;;
            esac

            echo -e "  ${GREEN}[OPEN]${RESET} Port ${WHITE}$port${RESET}"
            if [ -n "$bg_banner" ]; then
                echo "$bg_banner" | while IFS= read -r bline; do
                    [ -n "$bline" ] && echo -e "         ${DIM}$bline${RESET}"
                done
            fi
        fi
    done

    echo -e "\n${DIM}  Scan complete.${RESET}"
    press_enter
}

# ─────────────────────────────────────────
# MODULE 17: SEARCH HISTORY
# ─────────────────────────────────────────
view_history() {
    banner
    section "SEARCH HISTORY"

    if [ ! -f "$HISTORY_FILE" ] || [ ! -s "$HISTORY_FILE" ]; then
        echo -e "  ${YELLOW}[!] No search history yet.${RESET}"
        press_enter; return
    fi

    echo -e "  ${WHITE}History file:${RESET} ${CYAN}$HISTORY_FILE${RESET}\n"

    echo -ne "${GREEN}  [?] Search history (keyword or press Enter for all): ${RESET}"
    read -r hist_search

    echo ""
    if [ -z "$hist_search" ]; then
        tail -50 "$HISTORY_FILE" | while IFS= read -r line; do
            echo -e "  ${DIM}$line${RESET}"
        done
    else
        grep -i "$hist_search" "$HISTORY_FILE" 2>/dev/null | while IFS= read -r line; do
            echo -e "  ${GREEN}►${RESET} $line"
        done
        if ! grep -qi "$hist_search" "$HISTORY_FILE" 2>/dev/null; then
            echo -e "  ${DIM}  No results found for '$hist_search'${RESET}"
        fi
    fi

    echo ""
    echo -ne "${GREEN}  [?] Clear history? (y/N): ${RESET}"
    read -r clear_hist
    if [[ "$clear_hist" == "y" || "$clear_hist" == "Y" ]]; then
        > "$HISTORY_FILE"
        echo -e "  ${GREEN}[✓] History cleared.${RESET}"
    fi

    press_enter
}

# ─────────────────────────────────────────
# MODULE 18: VIEW REPORTS
# ─────────────────────────────────────────
view_reports() {
    banner
    section "SAVED REPORTS"

    shopt -s nullglob
    local files=("$REPORT_DIR"/*)
    shopt -u nullglob

    if [ ${#files[@]} -eq 0 ]; then
        echo -e "  ${YELLOW}[!] No reports saved yet.${RESET}"
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
# MODULE 19: EXPORT REPORTS TO ZIP
# ─────────────────────────────────────────
export_reports() {
    banner
    section "EXPORT REPORTS TO ZIP"

    shopt -s nullglob
    local files=("$REPORT_DIR"/*)
    shopt -u nullglob

    if [ ${#files[@]} -eq 0 ]; then
        echo -e "  ${YELLOW}[!] No reports to export.${RESET}"
        press_enter; return
    fi

    local zip_name="nw_osint_reports_$(date '+%Y%m%d_%H%M%S').zip"
    local zip_path="$HOME/$zip_name"

    echo -e "  ${CYAN}[*] Exporting ${#files[@]} reports...${RESET}"

    if zip -j "$zip_path" "${files[@]}" &>/dev/null; then
        echo -e "  ${GREEN}[✓] Exported successfully!${RESET}"
        echo -e "  ${WHITE}File :${RESET} $zip_path"
        echo -e "  ${WHITE}Size :${RESET} $(wc -c < "$zip_path") bytes"
    else
        echo -e "  ${RED}[!] Export failed. Is zip installed?${RESET}"
        echo -e "  ${DIM}  Run: pkg install zip -y${RESET}"
    fi

    press_enter
}

# ─────────────────────────────────────────
# MODULE 20: API KEY MANAGER
# ─────────────────────────────────────────
api_manager() {
    banner
    section "API KEY MANAGER"

    echo -e "  ${WHITE}Config file:${RESET} ${CYAN}$CONFIG_FILE${RESET}\n"

    # Show current keys
    echo -e "${YELLOW}  ── SAVED KEYS ──────────────────────────────${RESET}"
    local shodan_key="" abuse_key=""
    [ -f "$CONFIG_FILE" ] && {
        shodan_key=$(grep "^SHODAN_API=" "$CONFIG_FILE" 2>/dev/null | tail -1 | cut -d'=' -f2-)
        abuse_key=$(grep "^ABUSEIPDB_API=" "$CONFIG_FILE" 2>/dev/null | tail -1 | cut -d'=' -f2-)
    }

    if [ -n "$shodan_key" ]; then
        echo -e "  ${GREEN}[✓]${RESET} Shodan API     : ${DIM}${shodan_key:0:8}...${RESET}"
    else
        echo -e "  ${RED}[✗]${RESET} Shodan API     : Not set"
    fi

    if [ -n "$abuse_key" ]; then
        echo -e "  ${GREEN}[✓]${RESET} AbuseIPDB API  : ${DIM}${abuse_key:0:8}...${RESET}"
    else
        echo -e "  ${RED}[✗]${RESET} AbuseIPDB API  : Not set"
    fi

    echo -e "\n${YELLOW}  ── MANAGE ──────────────────────────────────${RESET}"
    echo -e "  ${RED}[1]${RESET} Set Shodan API key"
    echo -e "  ${RED}[2]${RESET} Set AbuseIPDB API key"
    echo -e "  ${RED}[3]${RESET} Delete all saved keys"
    echo -e "  ${RED}[0]${RESET} Back"
    echo ""
    echo -ne "  ${GREEN}Choice: ${RESET}"
    read -r api_choice

    case "$api_choice" in
        1)
            echo -e "\n  ${DIM}Get free key: https://account.shodan.io${RESET}"
            echo -ne "${GREEN}  [?] Enter Shodan API key: ${RESET}"
            read -r new_key
            if [ -n "$new_key" ]; then
                local verify
                verify=$(curl -s --max-time 10 "https://api.shodan.io/api-info?key=$new_key" 2>/dev/null)
                if echo "$verify" | jq -e '.query_credits' &>/dev/null; then
                    [ -f "$CONFIG_FILE" ] && grep -v "^SHODAN_API=" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
                    echo "SHODAN_API=$new_key" >> "$CONFIG_FILE"
                    echo -e "  ${GREEN}[✓] Shodan key saved! Credits: $(echo "$verify" | jq -r '.query_credits')${RESET}"
                else
                    echo -e "  ${RED}[!] Invalid key.${RESET}"
                fi
            fi
            ;;
        2)
            echo -e "\n  ${DIM}Get free key: https://www.abuseipdb.com/register${RESET}"
            echo -ne "${GREEN}  [?] Enter AbuseIPDB API key: ${RESET}"
            read -r new_key
            if [ -n "$new_key" ]; then
                local verify
                verify=$(curl -s --max-time 10 \
                    "https://api.abuseipdb.com/api/v2/check?ipAddress=8.8.8.8&maxAgeInDays=90" \
                    -H "Key: $new_key" -H "Accept: application/json" 2>/dev/null)
                if echo "$verify" | jq -e '.data.abuseConfidenceScore' &>/dev/null; then
                    [ -f "$CONFIG_FILE" ] && grep -v "^ABUSEIPDB_API=" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
                    echo "ABUSEIPDB_API=$new_key" >> "$CONFIG_FILE"
                    echo -e "  ${GREEN}[✓] AbuseIPDB key saved!${RESET}"
                else
                    echo -e "  ${RED}[!] Invalid key.${RESET}"
                fi
            fi
            ;;
        3)
            echo -ne "${YELLOW}  [?] Delete all keys? (y/N): ${RESET}"
            read -r confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                rm -f "$CONFIG_FILE"
                echo -e "  ${GREEN}[✓] All keys deleted.${RESET}"
            fi
            ;;
    esac
    press_enter
}

# ─────────────────────────────────────────
# MAIN MENU
# ─────────────────────────────────────────
main_menu() {
    while true; do
        banner
        echo -e "  ${WHITE}${BOLD}  MODULES${RESET}\n"
        echo -e "  ${RED}[01]${RESET} ${WHITE}Username OSINT${RESET}          ${DIM}Search 30+ platforms in parallel${RESET}"
        echo -e "  ${RED}[02]${RESET} ${WHITE}IP Address OSINT${RESET}         ${DIM}Geolocate, ASN, abuse reputation${RESET}"
        echo -e "  ${RED}[03]${RESET} ${WHITE}Domain / Website OSINT${RESET}   ${DIM}WHOIS, DNS, SSL expiry, redirect${RESET}"
        echo -e "  ${RED}[04]${RESET} ${WHITE}Email OSINT${RESET}              ${DIM}Breach check, Gravatar, MX lookup${RESET}"
        echo -e "  ${RED}[05]${RESET} ${WHITE}Phone Number OSINT${RESET}       ${DIM}60+ countries, E.164, WA/TG check${RESET}"
        echo -e "  ${RED}[06]${RESET} ${WHITE}Network OSINT${RESET}            ${DIM}IP, DNS leak, speed, open ports${RESET}"
        echo -e "  ${RED}[07]${RESET} ${WHITE}Google Dorking${RESET}           ${DIM}Auto-generate dork queries${RESET}"
        echo -e "  ${RED}[08]${RESET} ${WHITE}Website Fingerprint${RESET}      ${DIM}CMS, frameworks, CDN, SSL${RESET}"
        echo -e "  ${RED}[09]${RESET} ${WHITE}Wayback Machine${RESET}          ${DIM}View archived site snapshots${RESET}"
        echo -e "  ${RED}[10]${RESET} ${WHITE}GitHub OSINT${RESET}             ${DIM}Profile, repos, gists, orgs${RESET}"
        echo -e "  ${RED}[11]${RESET} ${WHITE}Shodan Lookup${RESET}            ${DIM}Exposed devices & CVEs${RESET}"
        echo -e "  ${RED}[12]${RESET} ${WHITE}DNS Brute Force${RESET}          ${DIM}100+ subdomain wordlist scan${RESET}"
        echo -e "  ${RED}[13]${RESET} ${WHITE}Hash Identifier${RESET}          ${DIM}Identify & crack MD5/SHA hashes${RESET}"
        echo -e "  ${RED}[14]${RESET} ${WHITE}MAC Address Lookup${RESET}       ${DIM}Vendor & manufacturer from MAC${RESET}"
        echo -e "  ${RED}[15]${RESET} ${WHITE}URL Expander${RESET}             ${DIM}Unshorten & trace redirect chain${RESET}"
        echo -e "  ${RED}[16]${RESET} ${WHITE}Banner Grabber${RESET}           ${DIM}Grab service banners from ports${RESET}"
        echo -e "  ${RED}[17]${RESET} ${WHITE}Search History${RESET}           ${DIM}Browse & search past queries${RESET}"
        echo -e "  ${RED}[18]${RESET} ${WHITE}View Reports${RESET}             ${DIM}Browse all saved results${RESET}"
        echo -e "  ${RED}[19]${RESET} ${WHITE}Export Reports to ZIP${RESET}    ${DIM}Bundle all reports into one file${RESET}"
        echo -e "  ${RED}[20]${RESET} ${WHITE}API Key Manager${RESET}          ${DIM}Add/update/delete API keys${RESET}"
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
            12)    dns_brute ;;
            13)    hash_lookup ;;
            14)    mac_lookup ;;
            15)    url_expander ;;
            16)    banner_grabber ;;
            17)    view_history ;;
            18)    view_reports ;;
            19)    export_reports ;;
            20)    api_manager ;;
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
# CLEANUP TRAP
# ─────────────────────────────────────────
cleanup() {
    rm -rf "$TEMP_DIR"/uscan_* "$TEMP_DIR"/dns_* 2>/dev/null
}
trap cleanup EXIT INT TERM

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
