#!/bin/bash

function cred() {
     if [[ $1 == "code" ]]; then
          eval "$(ssh-agent -s)"
          ssh-add ~/.ssh/id_rsa_file
          git config --local user.name "some"
          git config --local user.email "some@example.com"
     elif [[ $1 == "-h" ]]; then
          echo "option: code         > keys for github"
          echo "default: who         > show credentials for working directory"
     elif [[ $1 == "who" || -z $1 ]]; then
          git config --local user.name
          git config --local user.email
          git remote -v
     fi
}
