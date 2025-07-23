#!/bin/bash

# Mostrar ayuda si no hay argumentos o si se usa -h o --help
if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Uso: $(basename "$0") [opciones] segmento1 segmento2 ..."
    echo
    echo "Descripción:"
    echo "  Genera combinaciones incrementales de rutas API desde 1 hasta N segmentos,"
    echo "  sin barra inicial, separando solo con '/' entre elementos."
    echo
    echo "Ejemplo:"
    echo "  $(basename "$0") v1 user graphql --dash"
    echo
    echo "Resultado:"
    echo "  v1/"
    echo "  user/"
    echo "  graphql/"
    echo "  v1/user/"
    echo "  user/v1/"
    echo "  ..."
    echo
    echo "Opciones:"
    echo "  --dash          Añade una barra al final de cada combinación (ej. param/param/)"
    echo "  -h, --help      Muestra esta ayuda y termina"
    exit 0
fi

# Detectar flag --dash
ADD_DASH=false
ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "--dash" ]]; then
        ADD_DASH=true
    else
        ARGS+=("$arg")
    fi
done

# Función para generar permutaciones
permute() {
    local prefix=$1
    shift
    local arr=("$@")
    local len=${#arr[@]}

    if [ "$len" -eq 0 ]; then
        if [ "$ADD_DASH" = true ]; then
            echo "${prefix}/"
        else
            echo "$prefix"
        fi
    else
        for i in "${!arr[@]}"; do
            local next="${arr[i]}"
            local rest=("${arr[@]:0:i}" "${arr[@]:i+1}")
            if [ -z "$prefix" ]; then
                permute "$next" "${rest[@]}"
            else
                permute "$prefix/$next" "${rest[@]}"
            fi
        done
    fi
}

# Función para generar combinaciones de tamaño k
combine() {
    local k=$1
    shift
    local arr=("$@")
    local n=${#arr[@]}
    if (( k == 0 )); then
        echo ""
        return
    fi
    if (( k > n )); then
        return
    fi
    for (( i=0; i<=n-k; i++ )); do
        local head=${arr[i]}
        local tail=("${arr[@]:i+1}")
        while read -r sub; do
            if [ -z "$sub" ]; then
                echo "$head"
            else
                echo "$head $sub"
            fi
        done < <(combine $((k - 1)) "${tail[@]}")
    done
}

# Generar combinaciones y permutarlas
n=${#ARGS[@]}
for (( k=1; k<=n; k++ )); do
    while read -r combo; do
        read -ra parts <<< "$combo"
        permute "" "${parts[@]}"
    done < <(combine "$k" "${ARGS[@]}")
done
