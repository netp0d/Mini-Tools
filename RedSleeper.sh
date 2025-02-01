#!/bin/bash


### Created by Netp0d

# Function to validate if an IP address is in correct format
validate_ip() {
  local ip=$1
  local stat=1
  # Check if IP matches the pattern of four octets (0-255)
  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    # Split the IP by dots and check if each octet is between 0 and 255
    IFS='.' read -r -a octets <<< "$ip"
    if [ "${octets[0]}" -le 255 ] && [ "${octets[1]}" -le 255 ] && [ "${octets[2]}" -le 255 ] && [ "${octets[3]}" -le 255 ]; then
      stat=0
    fi
  fi
  return $stat
}

# Function to validate if a subnet is in correct CIDR format (e.g., 192.168.1.0/24)
validate_subnet() {
  local subnet=$1
  local stat=1
  if [[ $subnet =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$ ]]; then
    IFS='/' read -r ip mask <<< "$subnet"
    # Validate IP address
    validate_ip "$ip"
    stat=$?
  fi
  return $stat
}

# Function to check if a file exists and is not empty
validate_file() {
  local file=$1
  if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found!"
    return 1
  elif [ ! -s "$file" ]; then
    echo "Error: File '$file' is empty!"
    return 1
  fi
  return 0
}

# Function to validate if a list of IPs is in the correct format
validate_ip_list() {
  local ips=$1
  for ip in $ips; do
    validate_ip "$ip"
    if [ $? -ne 0 ]; then
      echo "Error: Invalid IP address $ip"
      return 1
    fi
  done
  return 0
}

# Check if the required arguments are provided
if [ $# -lt 3 ]; then
  echo "Usage: $0 <IP_or_subnet_or_list_or_file> <sleep_duration> <command>"
  exit 1
fi




input=$1
sleep_duration=$2
command=$3

# Validate the sleep duration (must be a positive integer)
if ! [[ "$sleep_duration" =~ ^[0-9]+$ ]] || [ "$sleep_duration" -le 0 ]; then
  echo "Error: Invalid sleep duration. Please provide a positive integer."
  exit 1
fi


# Display hacker banner
clear
echo "Initializing..."
sleep 1
echo -e "\033[1;32m"
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
echo -e "\033[0m"

# Sleep for suspense
sleep 2



echo "Running the command the user inputed: $command" 
echo " Let's go to sleep..."

# Sleep for suspense
sleep 2
echo -e "\033[1;32m"

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
    echo "File '$file' not found!"
    exit 1
  fi
  cat "$file"
}

# Handle the different types of input
if [[ $input =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  # Single IP
  echo "Validating IP: $input"
  if ! validate_ip "$input"; then
    echo "Error: Invalid IP address format."
    exit 1
  fi
  echo "Running command '$command' on single IP: $input"
  eval "$command $input"

elif [[ $input =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
  # Subnet (e.g., 192.168.1.0/24)
  echo "Validating subnet: $input"
  if ! validate_subnet "$input"; then
    echo "Error: Invalid subnet format."
    exit 1
  fi
  echo "Running command '$command' on all IPs in subnet: $input"
  for ip in $(generate_ips $input); do
    echo -e "\033[1;33mRunning command '$command' on IP: $ip\033[0m"
    eval "$command $ip"
    echo -e "\033[1;32mSleeping for $sleep_duration seconds...\033[0m"
    sleep $sleep_duration
  done

elif [[ -f "$input" ]]; then
  # Text file containing IPs
  echo "Validating file: $input"
  if ! validate_file "$input"; then
    exit 1
  fi
  echo "Running command '$command' on IPs from file: $input"
  for ip in $(read_ips_from_file $input); do
    if ! validate_ip "$ip"; then
      echo "Error: Invalid IP address in file: $ip"
      continue
    fi
    echo -e "\033[1;33mRunning command '$command' on IP: $ip\033[0m"
    eval "$command $ip"
    echo -e "\033[1;32mSleeping for $sleep_duration seconds...\033[0m"
    sleep $sleep_duration
  done

else
  # List of IPs (e.g., 192.168.1.1 192.168.1.3 192.168.1.5)
  echo "Validating list of IPs: $input"
  if ! validate_ip_list "$input"; then
    exit 1
  fi
  echo "Running command '$command' on specific IPs: $input"
  for ip in $input; do
    echo -e "\033[1;33mRunning command '$command' on IP: $ip\033[0m"
    eval "$command $ip"
    echo -e "\033[1;32mSleeping for $sleep_duration seconds...\033[0m"
    sleep $sleep_duration
  done
fi
