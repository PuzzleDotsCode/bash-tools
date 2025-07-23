#!/bin/bash

# Script básico para configurar iptables en Kali
# Flags disponibles:
#   --harden       : Aplica la configuración segura por defecto
#   --ssh          : Permite SSH en puerto 22
#   --reset        : Resetea las reglas y guarda backup en default-rules.txt
#   --file <file>  : Carga reglas desde un archivo y omite el resto
#   --show         : Muestra las reglas activas de iptables y sale
#   -h, --help     : Muestra esta ayuda

show_help() {
  echo "Uso: sudo $0 [--harden] [--ssh] [--reset] [--file <archivo.rules>] [--show]"
  echo ""
  echo "Opciones:"
  echo "  --harden       Aplica configuración segura predeterminada"
  echo "  --ssh          Permite acceso SSH entrante (puerto 22)"
  echo "  --reset        Limpia todas las reglas actuales y guarda backup en default-rules.txt"
  echo "  --file <file>  Carga reglas desde un archivo usando iptables-restore (omite el resto)"
  echo "  --show         Muestra las reglas de iptables y termina"
  echo "  -h, --help     Muestra esta ayuda"
  exit 0
}

ALLOW_SSH=false
DO_RESET=false
RULES_FILE=""
DO_HARDEN=false
SHOW_RULES=false
BACKUP_FILE="default-rules.txt"

# --- Mostrar ayuda si no hay argumentos ---
if [[ $# -eq 0 ]]; then
  show_help
fi

# --- Procesamiento de argumentos ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ssh)
      ALLOW_SSH=true
      shift
      ;;
    --reset)
      DO_RESET=true
      shift
      ;;
    --file)
      if [[ -n "$2" && -f "$2" ]]; then
        RULES_FILE="$2"
        shift 2
      else
        echo "[!] Debes especificar un archivo válido después de --file."
        exit 1
      fi
      ;;
    --harden)
      DO_HARDEN=true
      shift
      ;;
    --show)
      SHOW_RULES=true
      shift
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo "[!] Opción desconocida: $1"
      show_help
      ;;
  esac
done

# --- Verificación de permisos ---
if [[ $EUID -ne 0 ]]; then
  echo "[!] Este script debe ejecutarse como root."
  exit 1
fi

# --- Mostrar reglas actuales si se solicitó ---
if $SHOW_RULES; then
  echo "[+] Reglas activas de iptables:"
  iptables -L -v -n
  exit 0
fi

# --- Si se usa --file, aplicar archivo y salir ---
if [[ -n "$RULES_FILE" ]]; then
  echo "[+] Aplicando reglas desde archivo: $RULES_FILE"
  iptables-restore < "$RULES_FILE"
  echo "[✔] Reglas restauradas desde archivo."
  iptables -L -v -n
  exit 0
fi

# --- Si no se usa ninguna acción concreta, mostrar ayuda ---
if ! $DO_HARDEN && ! $DO_RESET && ! $ALLOW_SSH; then
  echo "[!] No se especificó ninguna acción relevante. Usa --harden, --file, --reset, --show o --ssh."
  show_help
fi

# --- Backup y reset de reglas ---
if $DO_RESET; then
  echo "[+] Guardando reglas actuales en '$BACKUP_FILE'..."
  iptables-save > "$BACKUP_FILE"
  echo "[+] Reseteando todas las reglas..."
  iptables -F
  iptables -X
fi

# --- Aplicación de reglas por defecto si se especificó --harden ---
if $DO_HARDEN; then
  echo "[+] Estableciendo políticas por defecto..."
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT ACCEPT

  echo "[+] Permitiendo tráfico local (lo)..."
  iptables -A INPUT -i lo -j ACCEPT

  echo "[+] Permitiendo conexiones ESTABLISHED,RELATED..."
  iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
fi

# --- SSH opcional ---
if $ALLOW_SSH; then
  echo "[+] Permitido acceso por SSH en puerto 22 (por --ssh)..."
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT
fi

echo "[✔] Reglas aplicadas con éxito."
iptables -L -v -n

