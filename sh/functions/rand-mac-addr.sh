rand-mac-addr() {
 hexdump -C /dev/urandom|cut-hexnum |cut -d' ' -f1,2,3,4,5,6|sed 's, ,:,g'|head -n1
}
