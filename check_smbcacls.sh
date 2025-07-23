#!/bin/bash

# Función para mostrar el uso del script
usage() {
    echo "Uso:"
    echo "$0 -s SMB_SERVER -c CREDENTIALS [-m PATTERN]"
    echo ""
    echo "Ejemplo:"
    echo './check_smbcacls.sh -s "//10.10.10.248/Users" -c "intelligent.htb\\Tiffany.Molina%NewIntelligenceCorpUser9876" -m "Everyone|Full"'
    exit 1
}

# Variables por defecto
SMB_SERVER=""
CREDENTIALS=""
PATTERN="Everyone"

# Procesar las opciones de línea de comandos
while getopts "s:c:m:" opt; do
    case $opt in
        s)
            SMB_SERVER=$OPTARG
            ;;
        c)
            CREDENTIALS=$OPTARG
            ;;
        m)
            PATTERN=$OPTARG
            ;;
        \?)
            echo "Opción inválida: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "La opción -$OPTARG requiere un argumento." >&2
            usage
            ;;
    esac
done

# Verificar que se hayan proporcionado los parámetros necesarios
if [[ -z "$SMB_SERVER" || -z "$CREDENTIALS" ]]; then
    usage
fi

# Función para listar todos los archivos y directorios recursivamente
list_smb_dirs() {
    local current_dir="$1"
    smbclient "$SMB_SERVER" -U "$CREDENTIALS" -D "$current_dir" -c "ls" | while read -r line; do
        # Obtener nombre de archivo/directorio y su tipo
        NAME=$(echo "$line" | awk '{print $1}')
        TYPE=$(echo "$line" | awk '{print $2}')

        # Ignorar los directorios especiales "." y ".."
        if [[ "$NAME" == "." || "$NAME" == ".." ]]; then
            continue
        fi

        # Procesar subdirectorios y archivos
        if [[ "$TYPE" == "D"* ]]; then
            local subdir="$current_dir/$NAME"
            echo "$subdir" # Agregar subdirectorio
            list_smb_dirs "$subdir" # Llamada recursiva para subdirectorio
        elif [[ "$TYPE" == "A"* ]]; then
            local file="$current_dir/$NAME"
            echo "$file" # Agregar archivo si es necesario
        fi
    done
}

# Listar el contenido inicial desde la raíz
list_smb_dirs "" | while read -r path; do
    echo ">> [*] Procesando $path"
    smbcacls -U "$CREDENTIALS" "$SMB_SERVER" "$path" | grep -iE "$PATTERN"
    echo ""
done

