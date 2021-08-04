#!/bin/bash
#
#   proxychecker.sh: Fast and easy proxy checker.
#   Author: Jose Maria Zaragoza.
#   January 2021 - Script Creation.
#   Version = 0.1
#   CURL is needed: apt-get install curl.

banner() {
        echo ""
        echo "----------------------------------"
        echo "|      Open Proxy Checker        |"
        echo "|                                |"
        echo "| Usage:                         |"
        echo "| bash proxychecker.sh IP:PORT   |"
        echo "| bash proxyxhexker.sh -f file   |"
        echo "| The file format must be ip:port|"
        echo "----------------------------------"
        echo ""
        sleep 1
}

#Check List
checkList() {
        echo "[!]IPs to check:"
        for i in $(cat $1)
        do
        proxyCheck $i
        done
}

#Check IP
proxyCheck(){
        code=$(curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0" -s -m 5 --proxy $1 http://info.cern.ch/hypertext/WWW/TheProject.html -I | grep HTTP/ | awk -F " " '{print $2}')
        code1=200
	if [ $code = $code1 ] 2>/dev/null; then
        echo "[+]http://"$1" Allows http trafic"
	echo $1 >> WorkingProxy.txt
        else
	 if [ -z $code] 2>/dev/null; then
          echo "[-]http://"$1" Do not seems to allow http trafic"
	  echo "[!]ErrorCode:TimeOut"
	 else
	  echo "[-]http://"$1" Do not seems to allow http trafic"
	  echo "[!]Error Code:"$code
	 fi
        fi
}

#Main
rm WorkingProxy.txt 2>/dev/null
banner
if [ $1 == "-f" ] 2>/dev/null; then
checkList $2
else
proxyCheck $1
fi
echo " "
echo "[!!]Working Proxy:"
cat WorkingProxy.txt
sleep 2
echo ""
echo "[!!]Check the WorkingProxy.txt file to see the results"
exit
