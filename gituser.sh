#!/bin/bash

sshpath="$HOME/.ssh"
createsshcreds=0
setgitcreds=0
setsshcreds=0
sshconfigfile="$sshpath/config"

# Colors
## Warning
YELLOW='\033[1;33m'
## No color code (resets the color to default)
NC='\033[0m'

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
    echo "cfg    Create SSH config file in '$sshpath' (required for SSH Identities in GIT)"
    echo "-a     Add SSH identity in SSH config file in '$sshpath' (required for SSH Identities in GIT)"
    echo "get    Get SSH credentials files from '$sshpath'"
    echo "who    Get GIT credentials from current location"
    echo "-g     Set GIT credentials from current location"
    echo
    Usage
}

Syntax() {
    echo "|- Syntax: cred [-flag] [data]"
    echo
    echo "Create SSH credentials in '$sshpath'"
    echo "cred -c 'filename' 'email@example.com'"
    echo
    echo "Set SSH credentials from '$sshpath'"
    echo "cred -s 'filename'"

    echo
    echo "Add SSH identity in SSH config file in '$sshpath' (required for SSH Identities in GIT)"
    echo "cred -a 'filename'"
    echo

    echo "Set GIT credentials from current location"
    echo "cred -g 'username' 'email@example.com'"
}

while getopts "a:hcsg" opt; do
    case ${opt} in
    h) help=1 ;;
    c) createsshcreds=1 ;;
    s) setsshcreds=1 ;;
    a) adduser=$OPTARG ;;
    g) setgitcreds=1 ;;
    \?)
        Syntax
        exit 1
        ;;
    esac
done

if [ -z "$1" ]; then
    Syntax
    exit 0
fi

# Check for help firĸst
if [ "$help" ]; then
    Help
    exit 0
fi

ADD_CONFIG() {
    echo "Host $1" >> "$sshconfigfile"
    echo "  HostName github.com" >> "$sshconfigfile"
    echo "  User git" >> "$sshconfigfile"
    echo "  IdentityFile $sshpath/$1" >> "$sshconfigfile"
    echo "" >> "$sshconfigfile"
}

CONFIG_FILE() {
    if [ ! -f "$sshconfigfile" ]; then
        echo "[-] Creating SSH config file... (required)"
        touch "$sshconfigfile"
        chmod +x "$sshconfigfile"
        ADD_CONFIG "$1"
    else
        echo "[-] SSH config file exist (required)"
        ADD_CONFIG "$1"
    fi
}

SSH_ADD_ID() {
    # enable ssh-agent
    eval "$(ssh-agent -s)"
    # Register with ssh-agent the new SSH Keys
    ssh-add "$sshpath/$1"
    # List registered SSH Keys
    ssh-add -l
    # ssh -vT git@guthub.com
}

# Create SSH credentials
if [ "$createsshcreds" -eq 1 ]; then
    echo "[-] Creating credentials for email: '$3' in file: '$2'"
    if [ -f "$sshpath/$2" ]; then
        echo ">! Error: The file '$2' already exist, choose a different file name"
        exit 1
    fi

    CONFIG_FILE "$2"

    if [ -n "$2" ] && [ -n "$3" ]; then
        echo "> email address: '$3' - file: '$2'"
        # check dir: exist=true<opposite
        if [ ! -d "$sshpath" ]; then
            echo "[-] Creating ~/.ssh folder to hold credentials"
            mkdir "$sshpath"
            chmod 700 "$sshpath"
        fi
        # Generating a SSH key
        ssh-keygen -t rsa -C "$3" -f "$sshpath/$2"
        # file permissions
        # chmod 600 "$sshpath/$2"
        chmod +x "$sshpath/$2"
        # chmod 644 "$sshpath/$2.pub"
        chmod +x "$sshpath/$2.pub"

        SSH_ADD_ID "$2"
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

    SSH_ADD_ID "$2"
fi

# Add SSH identity in SSH config file in '$sshpath' (required for SSH Identities in GIT)
if [ -n "$adduser" ]; then
    echo "[-] Add of SSH user in $sshconfigfile for GIT use"

    if [ ! -f "$sshpath/$adduser" ]; then
        echo
        echo -e "${YELLOW}>! Warning: The credential file '$sshpath/$adduser' does't exist,"
        echo -e ">! this means you are relating an user indentity not yet created ${NC}"
        echo
    fi

    CONFIG_FILE "$adduser"
    echo "Host added: $adduser"
    echo "IdentityFile related: $sshpath/$adduser"

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
    if [ ! -n "$2" ]; then
        Error "Username"
        exit 1
    fi
    if [ ! -n "$3" ]; then
        Error "Email address"
        exit 1
    fi
    git config --local user.name "$2"
    git config --local user.email "$3"
fi
