#!/bin/bash

# V2Ray Server-Side Setup: v0.0.0
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

# Convert certificates and private key to JSON format
cert_json="{
  \"certificate\": [
    \"$(cat ca.crt | sed -e 's/^/"/' -e 's/$/",/')\"
  ],
  \"key\": [
    \"$(cat ca.key | sed -e 's/^/"/' -e 's/$/",/')\"
  ]
}"

# Ask for user setup preference
print_message $PROCESS "Do you want to use the default setup? (yes/no)"
read -r setup_choice

# If default setup, generate UUID and use certificates
if [ "$setup_choice" = "yes" ]; then
  uuid=$(generate_uuid)
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
  echo "$config_json" > config.json
  print_message $DONE "Default setup configured."
else
  # Ask the user for configuration values
  print_message $PROCESS "Enter the necessary configuration values:"
  read -p "Enter UUID: " uuid
  read -p "Enter v2ray port: " v2ray_port
  read -p "Enter transport protocol (e.g., ws): " transport_protocol
  read -p "Enter security (e.g., tls): " security

  # Construct custom JSON configuration
  config_json="{
  \"log\": {
    \"loglevel\": \"warning\"
  },
  \"inbounds\": [
    {
      \"port\": $v2ray_port,
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
        \"network\": \"$transport_protocol\",
        \"security\": \"$security\",
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
  echo "$config_json" > config.json
  print_message $DONE "Custom setup configured."
fi

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

if [ "$setup_choice" = "yes" ]; then
  print_message $DONE "V2Ray Port: 43"
  print_message $DONE "UUID: $uuid"
  print_message $DONE "Transport Protocol: ws"
  print_message $DONE "Security: tls"
fi

print_message $DONE "Setup complete."
