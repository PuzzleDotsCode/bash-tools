#!/bin/bash

show_help() {
  echo "Use: sudo "$0" [--audit remote|local] [--reset] [--show remote|local] [-h|--help]"
  echo ""
  echo "Options:"
  echo "  --audit remote      See only public IP connections."
  echo "  --audit local       See only private o loopback IP connections."
  echo "  --show remote       See only remote public IP connections."
  echo "  --show local        See only private o local IP connections."
  echo "  --reset             Close processes listen on ports TCP/UDP."
  echo "  -h, --help          Show this help."
  exit 0
}

is_private_ip() {
  [[ "$1" =~ ^127\. ]] || [[ "$1" =~ ^10\. ]] || [[ "$1" =~ ^192\.168\. ]] || [[ "$1" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]
}

# -------------------------
# Option: --reset
# -------------------------
if [[ "$1" == "--reset" ]]; then
  echo "[+] Detecting port with status LISTEN..."
  LISTEN_PORTS=$(netstat -tuln | grep LISTEN | awk '{print $4}' | awk -F':' '{print $NF}' | sort -u)
  if [[ -z "$LISTEN_PORTS" ]]; then
    echo "[✔] Have not been found ports with status LISTEN."
    exit 0
  fi
  for PORT in $LISTEN_PORTS; do
    if [[ "$PORT" =~ ^[0-9]+$ ]]; then
      echo "[*] Closing process on port $PORT (TCP y UDP)..."
      fuser -k ${PORT}/tcp 2>/dev/null
      fuser -k ${PORT}/udp 2>/dev/null
    fi
  done
  echo "[✔] All detected ports has been closed (If possble)."
  exit 0
fi

# -------------------------
# Option: --show local
# -------------------------
if [[ "$1" == "--show" && "$2" == "local" ]]; then
  echo "[+] Active connections to public or private IPs:"
  ss -tunp | awk 'NR>1 {print $6, $5, $7}' | while read LOCAL REMOTE PROC; do
    RHOST=$(echo "$REMOTE" | cut -d: -f1)
    if is_private_ip "$RHOST"; then
      PORT=$(echo "$REMOTE" | cut -d: -f2)
      echo "[*] $REMOTE -> $LOCAL  "${PROC}""
    fi
  done
  exit 0
fi

# -------------------------
# Option: --show remote
# -------------------------
if [[ "$1" == "--show" && "$2" == "remote" ]]; then
  echo "[+] Active connections to public IPs:"
  netstat -tunp | awk 'NR>2 {print $5, $4, $7}' | while read REMOTE LOCAL PROC; do
    RHOST=$(echo "$REMOTE" | cut -d: -f1)
    if [[ "$RHOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && ! is_private_ip "$RHOST"; then
      PTR=$(dig -x "$RHOST" +short | tr -d '
')
      echo "[*] $LOCAL -> $REMOTE | $PROC | ${PTR:-N/A}"
    fi
  done
  exit 0
fi

# -------------------------
# Option: --audit remote
# -------------------------
if [[ "$1" == "--audit" && "$2" == "remote" ]]; then
  echo "[+] Pasive audit of active connections (remote):"
  netstat -tunp | awk 'NR>2 {print $5, $4, $7}' | while read REMOTE LOCAL PROC; do
    RHOST=$(echo "$REMOTE" | cut -d: -f1)
    if [[ "$RHOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && ! is_private_ip "$RHOST"; then
      echo ""
      echo "[*] $RHOST"
      echo "    Local Process: $PROC"
      echo "    Connection: $LOCAL -> $REMOTE"
      PTR=$(dig -x "$RHOST" +short)
      echo "    Inverse name: ${PTR:-N/A}"
      ORG=$(curl -s "https://ipinfo.io/$RHOST/org" || echo "Desconocido")
      echo "    Organization: ${ORG:-Desconocido}"
    fi
  done
  exit 0
fi

# -------------------------
# Option: --audit local
# -------------------------
if [[ "$1" == "--audit" && "$2" == "local" ]]; then
  echo "[+] Pasive audit of active connections (local):"
  ss -tunp | awk 'NR>1 {print $6, $5, $7}' | while read LOCAL REMOTE PROC; do
    RHOST=$(echo "$REMOTE" | cut -d: -f1)
    if [[ "$RHOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && is_private_ip "$RHOST"; then
      echo ""
      echo "[*] $RHOST"
      echo "    Local Process: $PROC"
      echo "    Connection: $LOCAL -> $REMOTE"
      PTR=$(dig -x "$RHOST" +short)
      echo "    Inverse name: ${PTR:-N/A}"
      echo "    Organization: Private IP o loopback — No external consulting"
      echo "    Class: Private"
    fi
  done
  exit 0
fi

show_help
