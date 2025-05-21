#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <problem-file>"
    exit 1
fi

PROBLEM_FILE="$1"
DOMAIN_FILE="maindomain.pddl"
ENHSP_DIR="."

java -jar "$ENHSP_DIR/enhsp-19.jar" -o "$DOMAIN_FILE" -f "$PROBLEM_FILE"
