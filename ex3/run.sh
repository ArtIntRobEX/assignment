#!/bin/bash

PROBLEM_FILE="problem2.pddl"
DOMAIN_FILE="domain.pddl"
ENHSP_DIR="../"

java -jar "$ENHSP_DIR/enhsp-19.jar" -o "$DOMAIN_FILE" -f "$PROBLEM_FILE" -sp
