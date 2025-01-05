#!/bin/bash

# for ((one=0; one<256; one++)); do 
#     echo "[*] Testing: $one.x.x.x"
#     for ((two=0; two<256; two++)); do 
#         echo "    + $one.$two.x.x"
#         for ((three=0; three<256; three++)); do 
#             echo "      - $one.$two.$three.x"
#             echo "        Checkig hosts..."
#             for ((four=0; four<256; four++)); do
#                 range="$one.$two.$three.$four"
#                 ping -w 1 -c 1 "$range" > /dev/null 2>&1 && echo "        + Host is up $range";
#             done
#         done
#     done
# done

# for ((i=0;i<10;i++));do \
#     ip_test="79.11$i.143.11$i"; \
#     #echo "ip_test: $ip_test"; \
#     ping -w 1 -c 1 "$ip_test"; \
#     ipinfo "$ip_test" > info.txt; \
#     cat info.txt | grep -i 'city';
#     cat info.txt | grep -i 'region'; \
#     cat info.txt | grep -i 'country'; \
#     cat info.txt | grep -i 'organization'; \
# done

