#!/bin/bash

# Variables
SMB_SERVER="//10.10.10.103/Department Shares"
CREDENTIALS="HTB.LOCAL\\amanda%Ashare1972"

# Función para listar todos los archivos y directorios recursivamente
list_smb_dirs() {
    smbclient "$SMB_SERVER" -U "$CREDENTIALS" -D "$1" -c "ls" | while read -r line; do
        # Obtener nombre de archivo/directorio y su tipo
        NAME=$(echo "$line" | awk '{print $1}')
        TYPE=$(echo "$line" | awk '{print $2}')

        # Ignorar los directorios especiales "." y ".."
        if [[ "$NAME" == "." || "$NAME" == ".." ]]; then
            continue
        fi

        # Procesar subdirectorios y archivos
        if [[ "$TYPE" == "D" ]]; then
            echo "$1/$NAME" # Agregar subdirectorio
            list_smb_dirs "$1/$NAME" # Llamada recursiva para subdirectorio
        elif [[ "$TYPE" == "A" ]]; then
            echo "$1/$NAME" # Agregar archivo si es necesario
        fi
    done
}

# Listar el contenido inicial desde la raíz
list_smb_dirs "" | while read -r path; do
    echo ">> [*] Procesando $path"
    # smbcacls -U "$CREDENTIALS" "$SMB_SERVER" "$path"
    smbcacls -U "$CREDENTIALS" "$SMB_SERVER" "$path" | grep -i 'Everyone'
    echo ""
done
