#!/bin/bash

sshpath="$HOME/.ssh"
createsshcreds=0
setgitcreds=0
setsshcreds=0

Error() {
    echo ">! Error: $1 not provided"
}

Check() {
    echo ">! Error: $1 not defined"
}

Usage() {
    echo "|- Examples:"
    echo "Create SSH credentials in '$sshpath'"
    echo "cred -c 'filename' 'email@example.com'"
    echo
    echo "Set SSH credentials from '$sshpath'"
    echo "cred -s 'filename'"
    echo
    echo "Get SSH credentials files from '$sshpath'"
    echo "cred get"
    echo
    echo "Get GIT credentials from current location"
    echo "cred who"
    echo
    echo "Set GIT credentials from current location"
    echo "cred -g 'username' 'email@example.com'"
}

Help() {
    echo "Getter/Setter for GIT/SSH credentials"
    echo
    echo "|- Syntax: "
    echo "cred [-flag] [data]"
    echo
    echo "|- Options:"
    echo "-c     Create SSH credentials in '$sshpath'"
    echo "-s     Set SSH credentials from '$sshpath'"
    echo "get    Get SSH credentials files from '$sshpath'"
    echo "who    Get GIT credentials from current location"
    echo "-g     Set GIT credentials from current location"
    echo
    Usage
}

while getopts ":hcsg" opt; do
    case ${opt} in
    h) help=1 ;;
    c) createsshcreds=1 ;;
    s) setsshcreds=1 ;;
    g) setgitcreds=1 ;;
    \?)
        Help
        exit 1
        ;;
    esac
done

if [ -z "$1" ]; then
    Help
    exit 0

fi

# Check for help firĸst
if [ "$help" ]; then
    Help
    exit 0
fi

# Create SSH credentials
if [ "$createsshcreds" -eq 1 ]; then
    echo "[-] Creating credentials for email: '$3' in file: '$2'"
    if [ -f "$sshpath/$2" ]; then
        echo ">! Error: The file '$2' already exist, choose a different file name"
        exit 1
    fi
    if [ -n "$2" ] && [ -n "$3" ]; then
        echo "> email address: '$3' - file: '$2'"
        if [ ! -d "$sshpath" ]; then
            echo "[-] Creating ~/.ssh folder to hold credentials"
            mkdir "$sshpath"
            chmod 700 "$sshpath"
        fi
        # Generating a SSH key
        ssh-keygen -t rsa -C "$3" -f "$sshpath/$2"
        # enable ssh-agent
        eval "$(ssh-agent -s)"
        # Register with ssh-agent the new SSH Keys
        ssh-add "$sshpath/$2"
    else
        Error "Username or Email address"
        exit 1
    fi
fi

# Set SSH credentials from current location
if [ "$setsshcreds" -eq 1 ]; then
    echo "[-] Set credentials for user: '$2'"
    if [ ! -f "$sshpath/$2" ]; then
        echo ">! Error: The file '$2' doesn't exist in '$HOME/.ssh'"
        echo ">! the credential file name must match the username"
        exit 1
    fi
    eval "$(ssh-agent -s)"
    ssh-add "$sshpath/$2"
fi

# Get SSH credentials files from $sshpath
if [ "$1" = "get" ]; then
    echo "[-] List of SSH credentials in $sshpath"
    echo

    if [ ! -d "$sshpath" ]; then
        echo ">! Error: $sshpath doesn't exists"
        exit 1
    fi
    
    publist=$(ls "$sshpath" | grep '.pub')
    for line in $(echo "$publist"); do
        echo "File: $line" | sed 's/\.pub//'
        regemail=$(cat "$sshpath/$line" | cut -d " " -f 3)
        echo "Account: $regemail"
        echo
    done
fi

# Get GIT credentials from current location
if [ "$1" = "who" ]; then
    if [ ! -d "$(pwd)/.git" ]; then
        echo ">! Error: Current location is not a GIT repository"
        exit 1
    fi
    echo "[-] Username:"
    git config --local user.name 2>/dev/null ||
        Check "Username"
    echo

    echo "[-] Email address:"
    git config --local user.email 2>/dev/null ||
        Check "Email address"
    echo

    echo "[-] Remote repository:"
    git remote -v 2>/dev/null ||
        Check "Remote repository"
fi

# Set GIT credentials from current location
if [ "$setgitcreds" -eq 1 ]; then
    echo "[-] Set credentials for user: '$2' with email: '$3'"
    if [ ! -d "$(pwd)/.git" ]; then
        echo ">! Error: Current location is not a GIT repository"
        exit 1
    fi
    if [ ! -n "$2" ] || [ ! -n "$3" ]; then
        Error "Username or Email address"
        exit 1
    fi
    git config --local user.name "$2"
    git config --local user.email "$3"
fi