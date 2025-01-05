#!/bin/bash

# Variables para los archivos de log
log1="log1.txt"
log2="log2.txt"

# Función para procesar un archivo de log y mostrar resultados
procesar_log() {
    local log_file="$1"

    echo "  > Procesando archivo: $log_file"
    if [[ -s "$log_file" ]]; then

        # Extraer puertos únicos y procesarlos
        awk 'NF{print $NF}' "$log_file" | sort -n | uniq | while read -r port; do
            # Verifica si el puerto es un número
            if [[ "$port" =~ ^[0-9]+$ ]]; then
                echo "    > Analizando puerto: $port"
                lsof_output=$(sudo lsof -i tcp:"$port" 2>/dev/null)
                if [[ -z "$lsof_output" ]]; then
                    echo "      \_(vv)_/ No sabemos qué es"
                else
                    echo "$lsof_output"
                fi
            else
                echo "    [X] Error: valor capturado no es un puerto válido: $port"
            fi
        done
    else
        echo "    [X] Archivo vacío o sin datos relevantes: $log_file"
    fi

    # Elimina el archivo de log después de procesarlo
    rm -f "$log_file"
    echo "[v] Archivo $log_file eliminado."
}

# Función para iniciar captura con tshark
iniciar_captura() {
    local log_file="$1"
    echo "[^] Iniciando captura en $log_file..."
    sudo tshark -i wlan0 -Y "ip.dst == 192.168.1.134" -T fields -e tcp.dstport >> "$log_file" 2>/dev/null &
    echo $!  # Retornar el PID del proceso
}

# Loop infinito para alternar entre log1 y log2
while true; do
    # Iniciar captura en log1
    tshark_pid=$(iniciar_captura "$log1")
    sleep 10  # Captura datos durante 10 segundos

    # Detener captura y procesar log1
    kill "$tshark_pid" 2>/dev/null
    procesar_log "$log1"

    # Iniciar captura en log2
    tshark_pid=$(iniciar_captura "$log2")
    sleep 10  # Captura datos durante 10 segundos

    # Detener captura y procesar log2
    kill "$tshark_pid" 2>/dev/null
    procesar_log "$log2"
done
