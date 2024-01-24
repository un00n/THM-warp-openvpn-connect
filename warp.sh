#!/bin/bash

#set -e  # Exit on any errors

# Print a header for clarity
echo "====== THM VPN Connection Script ======"

# Check Warp connection status
echo "Checking Warp connection status..."
warp_status="$(warp-cli status | grep 'Status:')"
if [[ $warp_status =~ "Status: Connected" ]]; then
    echo "Warp connected successfully."
else
    # Connect to Warp
    echo "Connecting to Warp..."
    warp-cli connect
    
fi
# Wait for warp-cli to establish a connection
sleep 3
# Check if an IP has been assigned
echo "Checking Warp IP assignment..."
if [[ $(hostname -I | awk '{print$2}') ]]; then
    echo "Warp IP assigned successfully: $(hostname -I | awk '{print$2}'))"
else
    echo "Warp IP assignment failed. Exiting."
    exit 1
fi

# Prompt user for OpenVPN configuration file path
echo "Enter the path to your OpenVPN configuration file (.ovpn):"
read -r openvpn_config_path

# Connect to OpenVPN (in the background)
echo "Connecting to OpenVPN (in background) using config: $openvpn_config_path..."
openvpn --config "$openvpn_config_path" &


# Wait for OpenVPN to establish a connection
sleep 10  # Adjust the sleep time if needed

# Check OpenVPN connection and IP
echo "Checking OpenVPN connection..."
if [[ $(hostname -I | awk '{print$2}') == $(ip addr | grep -oP 'inet 10.\d+\.\d+\.\d+') ]]; then
    echo "OpenVPN IP assigned successfully: $(ifconfig | grep -oP "inet \K[\d.]+" | grep -v 127.0.0.1)"
else
    echo "OpenVPN connection failed. Exiting."
    exit 1
fi

# Disconnect from Warp
echo "Disconnecting from Warp..."
warp-cli disconnect

# Second check: ping 10.10.10.10 -c 3
echo "Pinging 10.10.10.10..."
ping -c 3 10.10.10.10

echo "====== VPN Connection Established ======"
