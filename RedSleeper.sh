#!/bin/bash

# Check if at least two arguments are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <subnet_or_file> <sleep_duration>"
  exit 1
fi

# Display hacker banner
clear
echo "Initializing..."
sleep 1
echo -e "\033[1;31m"
cat << "EOF"

 _____               _    _____   _                                      
|  __ \             | |  / ____| | |                                     
| |__) |   ___    __| | | (___   | |   ___    ___   _ __     ___   _ __  
|  _  /   / _ \  / _` |  \___ \  | |  / _ \  / _ \ | '_ \   / _ \ | '__| 
| | \ \  |  __/ | (_| |  ____) | | | |  __/ |  __/ | |_) | |  __/ | |    
|_|  \_\  \___|  \__,_| |_____/  |_|  \___|  \___| | .__/   \___| |_|    
                                                   | |                   
                                                   |_|                

EOF
echo -e "\033[1;31m"

# Sleep for suspense
sleep 2



echo " Let's go to sleep... ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
echo ""
echo ""
echo "SHHHHHHHHHHHHHHHHH"
# Sleep for suspense
sleep 2
echo -e "\033[1;97m"

 
input=$1
sleep_duration=$2

# Validate sleep duration (must be a positive integer)
if ! [[ "$sleep_duration" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: Sleep duration must be a positive integer."
  exit 1
fi

# Function to generate IPs in a subnet (e.g., 192.168.1.0/24)
generate_ips() {
  local subnet=$1
  local base_ip=$(echo $subnet | cut -d '/' -f1)
  local base_ip_parts=($(echo $base_ip | tr '.' ' '))

  local network="${base_ip_parts[0]}.${base_ip_parts[1]}.${base_ip_parts[2]}"

  for i in $(seq 1 254); do
    echo "$network.$i"
  done
}

# Function to read IPs from a text file
read_ips_from_file() {
  local file=$1
  if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found!"
    exit 1
  fi
  cat "$file"
}

# Function to validate subnet format (e.g., 192.168.1.0/24)
validate_subnet() {
  local subnet=$1
  if ! [[ "$subnet" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
    echo "Error: '$subnet' is not a valid subnet format (e.g., 192.168.1.0/24)."
    exit 1
  fi
}

# Check if input is a subnet or a file
if [[ $input =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
  # Input is a subnet
  echo "Running on all IPs in subnet: $input"
  validate_subnet $input
  for ip in $(generate_ips $input); do
    echo "Running command on IP: $ip"
    # Example command to run (replace this with your own command)
    proxychains nxc smb $ip -u  -p '' --shares

    # Sleep after each iteration
    echo "Sleeping for $sleep_duration seconds..."
    sleep $sleep_duration
  done

elif [[ -f "$input" ]]; then
  # Input is a file containing IPs
  echo "Running on IPs from file: $input"
  for ip in $(read_ips_from_file $input); do
    echo "Running command on IP: $ip"
    # Example command to run (replace this with your own command) Make sure to add $ip where the subnet or IP should go
    proxychains nxc smb $ip -u  -p '' --shares

    # Sleep after each iteration
    echo "Sleeping for $sleep_duration seconds..."
    sleep $sleep_duration
  done

else
  echo "Error: Invalid input. Please provide a valid subnet (e.g., 192.168.1.0/24) or a file containing IPs."
  exit 1
fi
