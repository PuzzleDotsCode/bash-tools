#!/bin/bash

function audit_folders() {
    if [ -z "$1" ]; then
        AUDIT_PATH="audit_$(date +%y%m%d_%H%M%S)"
    else
        AUDIT_PATH="audit_$1"
    fi
    mkdir -p $AUDIT_PATH/{scans,content,exploits}
    touch $AUDIT_PATH/notes.md
    touch $AUDIT_PATH/report.md
}
audit_folders "$1"
