cpan-inst() {
 for_each 'verbosecmd -1+=cpan.inst.log -2=1 cpan -i "${1//-/::}" ;  verbosecmd writefile -a cpan.inst.$? "$1"'  ${@:-$(<~/cpan-inst.list)}
}
