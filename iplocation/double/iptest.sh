#!/bin/bash

# IP range
RANGE=10
# IP information
# IP="192.168.1.1" # range e.g. [.13x]
# IP="192.168.1.14" # range e.g. [.13x]
# IP="79.116.133.16" # range e.g. [.13x]
IP="79.116.133.1" # range e.g. [.13x]

for ((d=1;d<10;d++));do 
    TEST_SUBNET="$IP$d"
    # echo "$TEST_SUBNET"
    
    for ((i=1; i<$RANGE; i++)); do 
        TEST_IP="$TEST_SUBNET$i"
        # Capture IP information
        IP_TEST=$(ipinfo "$TEST_IP")
        # Capture ARP information
        ARP_TEST=$(arp -a "$TEST_IP")
        
        # Check if IP information was retrieved and extract location
        if [[ -n "$IP_TEST" ]]; then
            LOCATION=$(echo "$IP_TEST" | grep -i 'city' | awk '{print $NF}')
            DEVICE=$(echo "$ARP_TEST" | awk '{print $NF}')
            # Handle empty location if 'region' is not found
            LOCATION=${LOCATION:-'Location not enabled'}
        else
            LOCATION='Location not enabled'
        fi

        if [[ "$DEVICE" == "found." ]]; then
            # Handle Device not found
            echo "[*] IP test: $TEST_IP - ? - $LOCATION"
        else
            echo "[*] IP test: $TEST_IP - $DEVICE - $LOCATION"
        fi

done

# for ((i=1; i<$RANGE; i++)); do 
#     TEST_IP="$IP$i"
#     # Capture IP information
#     IP_TEST=$(ipinfo "$TEST_IP")
#     # Capture ARP information
#     ARP_TEST=$(arp -a "$TEST_IP")
    
#     # Check if IP information was retrieved and extract location
#     if [[ -n "$IP_TEST" ]]; then
#         LOCATION=$(echo "$IP_TEST" | grep -i 'region' | awk '{print $NF}')
#         DEVICE=$(echo "$ARP_TEST" | awk '{print $NF}')
#         # Handle empty location if 'region' is not found
#         LOCATION=${LOCATION:-'Location not enabled'}
#     else
#         LOCATION='Location not enabled'
#     fi

#     if [[ "$DEVICE" == "found." ]]; then
#         # Handle Device not found
#         echo "[*] IP test: $TEST_IP - ? - $LOCATION"
#     else
#         echo "[*] IP test: $TEST_IP - $DEVICE - $LOCATION"
#     fi

done

