#!/bin/bash

WIPE="$HOME/custom/tmp"

create=""
write=0

Hello() {
    echo "Welcome to Wopa: evidence  cleaner"
    echo
}
Hello

Help() {
    echo "|- Syntax: y/n"
    echo "wipeout: -f (fresh)/-c (create) / -d (delete) [option]"
    echo
    echo "|- Options:"
    echo "-f     Fresh /tmp evidence folder in '$WIPE'"
    echo "-c     Create /tmp evidence folder in '$WIPE'"
    echo "-d     Delete /tmp evidence folder in '$WIPE'"
    echo
    exit 0
}

Create_wipe() {
    echo "Fresh /tmp evidence folder in '$WIPE'"
    # create evidence folder
    mkdir -p "$WIPE"
}

Delete_wipe() {
    if [ ! -d "$WIPE" ]; then
        echo "no evidence in location '$WIPE'"
        exit 1
    fi
    echo "evidence bye bye location '$WIPE'"
    # create evidence folder
    rm -r "$WIPE"
}

Refresh_wipe() {
    if [ ! -d "$WIPE" ]; then
        echo "no evidence in location '$WIPE'"
        exit 1
    fi
    echo "wipping files's '$WIPE'"
    find "$WIPE" -type f -exec shred -u -n 5 -z {} \;
    echo "wipping folder '$WIPE'"
    find "$WIPE" -type d -empty -delete
    Create_wipe
}

if [ ! -z "$1" ]; then
    if [ "$1" = "-h" ]; then
        Help
        exit 0
    elif [ "$1" = "-f" ]; then
        Refresh_wipe
        exit 0
    elif [ "$1" = "-d" ]; then
        Delete_wipe
        exit 0
    fi
fi

if [ ! -d "$WIPE" ]; then
    echo "[x] $WIPE doesn't exist (required)"
    read -p "Create? y/n : " create

    if [ ! -z "$create" ]; then
        echo "Option selected: $create"
        if [ "$create" = "y" ]; then
            echo "[+] creating evidence folder"
            Create_wipe
            exit 0
        elif [ "$create" = "n" ]; then
            echo "[-] evidence folder doesn't exist"
            echo "and won't be created"
        else
            echo "[x] Allowed options: y/n"
        fi
    else
        echo "[-] Option not selected"
        echo "[-] evidence folder doesn't exist"
        echo "and won't be created"
    fi

    exit 1
else
    echo "[+] evidence exist in folder $WIPE"
    read -p "Fresh? y/n : " fresh
    if [ ! -z "$fresh" ]; then
        echo "Option selected: $fresh"
        if [ "$fresh" = "y" ]; then
            echo "[+] Refreshing evidence folder"
            Refresh_wipe
            exit 0
        elif [ "$fresh" = "n" ]; then
            echo "[-] evidence folder exist"
            echo "and won't be refrshed"
        else
            echo "[x] Allowed options: y/n"
        fi
    else
        echo "[-] Option not selected"
        echo "[-] evidence folder exist"
        echo "and won't be refreshed"
    fi

    exit 1
fi
