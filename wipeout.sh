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
    if [ ! -z "$1" ]; then
        echo "Fresh /tmp evidence folder in '$1'"
        # create evidence folder
        mkdir -p "$1"
    else
        echo "Fresh /tmp evidence folder in '$WIPE'"
        # create evidence folder
        mkdir -p "$WIPE"
    fi
}

Remove_data() {
    echo "wipping files's '$1'"
    find "$1" -type f -exec shred -u -n 5 -z {} \;
    echo "wipping folder '$1'"
    find "$1" -depth -type d -exec rm -rf {} \;
}

Delete_wipe() {
    if [ ! -d "$1" ]; then
        echo "no evidence in location '$1'"
        exit 1
    fi
    echo "evidence bye bye in location '$1'"
    Remove_data "$1"
}

Refresh_wipe() {
    if [ ! -d "$1" ]; then
        echo "no evidence in location '$1'"
        exit 1
    fi
    Delete_wipe "$1"
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
        if [ ! -z "$2" ]; then
            Delete_wipe "$2"
            exit 0
        else
            Delete_wipe "$WIPE"
            exit 0
        fi
    elif [ "$1" = "-c" ]; then
        if [ ! -z "$2" ]; then
            Create_wipe "$2"
            exit 0
        else
            Create_wipe "$WIPE"
            exit 0
        fi
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
