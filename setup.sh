#!/bin/bash

# V2Ray Server-Side Setup: v0.3.2
# Define colors for user-friendly printing
NORMAL='\e[97m'
PROCESS='\e[93m'
DONE='\e[92m'
ERROR='\e[91m'
RESET='\e[0m'

# Function to print user-friendly messages with colors
print_message() {
  local color="$1"
  local message="$2"
  echo -e "${color}${message}${RESET}"
}

# Function to generate UUID
generate_uuid() {
  uuidgen
}

# Update the system
print_message $PROCESS "Updating system..."
apt-get update
print_message $DONE "System update complete."

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null; then
  print_message $PROCESS "Installing OpenSSL..."
  apt-get install -y openssl
  print_message $DONE "OpenSSL installation complete."
fi

# Check if uuidgen is installed
if ! command -v uuidgen &> /dev/null; then
  print_message $PROCESS "Installing uuid-runtime..."
  apt-get install -y uuid-runtime
  print_message $DONE "uuid-runtime installation complete."
fi

# Install V2Ray
print_message $PROCESS "Installing V2Ray..."
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
print_message $DONE "V2Ray installation complete."

# Change directory
cd /usr/local/etc/v2ray/

# Delete the existing config.json
print_message $PROCESS "Deleting the existing config.json..."
rm -f config.json
print_message $DONE "Config.json deleted."

# Generate Certificate and RSA Private Key Pair
print_message $PROCESS "Generating Certificate and RSA Private Key Pair..."
openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 365 -nodes
print_message $DONE "Certificate and RSA Private Key Pair generated."

# Remove leading spaces and convert certificates and private key to JSON format
cert_json="[
{
  \"certificate\": [
$(awk 'NF {sub(/^\s+/, "", $0); print "    \"" $0 "\","}' ca.crt | sed '$ s/,$//')
  ],
  \"key\": [
$(awk 'NF {sub(/^\s+/, "", $0); print "    \"" $0 "\","}' ca.key | sed '$ s/,$//')
  ]
}
]"

# Generate a random UUID
uuid=$(generate_uuid)

# Configure V2Ray with default settings
config_json="{
  \"log\": {
    \"loglevel\": \"warning\"
  },
  \"inbounds\": [
    {
      \"port\": 43,
      \"listen\": \"0.0.0.0\",
      \"protocol\": \"vmess\",
      \"settings\": {
        \"clients\": [
          {
            \"id\": \"$uuid\"
          }
        ]
      },
      \"tag\": \"tag-vmess\",
      \"streamSettings\": {
        \"network\": \"ws\",
        \"security\": \"tls\",
        \"tlsSettings\": {
          \"serverName\": \"teams.microsoft.com\",
          \"allowInsecure\": true,
          \"alpn\": [
            \"http/1.1\"
          ],
          \"certificates\": $cert_json,
          \"disableSystemRoot\": true
        }
      }
    }
  ],
  \"outbounds\": [
    {
      \"protocol\": \"freedom\",
      \"settings\": {},
      \"tag\": \"direct\"
    }
  ]
}"

# Save the configuration to config.json
echo "$config_json" > config.json

# Enable and start V2Ray service
print_message $PROCESS "Enabling V2Ray service..."
systemctl enable v2ray
print_message $DONE "V2Ray service enabled."

print_message $PROCESS "Starting V2Ray service..."
service v2ray start
print_message $DONE "V2Ray service started."

# Sleep for 5 seconds
sleep 5

# Check V2Ray service status
print_message $PROCESS "Checking V2Ray service status..."
service v2ray status
print_message $DONE "V2Ray service status checked."

# Print server details
server_ip=$(hostname -I | awk '{print $1}')
print_message $DONE "Server IP: $server_ip"
print_message $DONE "V2Ray Port: 43"
print_message $DONE "UUID: $uuid"
print_message $DONE "Transport Protocol: ws"
print_message $DONE "Security: tls"

print_message $DONE "Setup complete."