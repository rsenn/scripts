wlan-schreyer () 
{ 
		sudo killall wpa_supplicant dhcpcd dhclient NetworkManager nm-applet
		sleep 1
		sudo killall -9 wpa_supplicant dhcpcd dhclient NetworkManager nm-applet
    sudo ifconfig wlan0 down
    sudo modprobe -r b43
    sudo modprobe b43
		sudo ifconfig wlan0 0 up
    sudo iwconfig wlan0 essid public1@schreyer.org;
    sudo ifconfig wlan0 192.168.3.213 up;
     #sudo route add default gw 192.168.3.1
		 sudo ip route del default
		 sudo ip route add default via 192.168.3.1
}
