#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found"
    exit
fi

# Extract arguments from the input into shell variables.
eval "$(jq -r '@sh "SSH_KEY=\(.ssh_key) SSH_USER=\(.ssh_user) FQDN=\(.fqdn)"')"

# Get kubeconfig from instance
KUBECONFIG=$(ssh -i ${SSH_KEY} ${SSH_USER}@${FQDN} -- sudo cat /etc/rancher/k3s/k3s.yaml | base64 -w0)

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg output "${KUBECONFIG}" '{"output":$output}'