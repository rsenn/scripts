#!/bin/sh
#
# Watch zattoo.com using mplayer or similar
#
# Usage: env EMAIL=enkilo@gmx.ch PASSSWORD=lala PLAYER=mplayer zattoo.sh n24_doku 


# German Zatto Channels:
#
#    3plus                hr                   prosieben            super-rtl           
#    3sat                 hse24                puls8                swiss_1             
#    4plus                hse24_extra          radio-bremen-tv      swr-fernsehen-bw    
#    anixe                hse24_trend          rbb                  tele-5              
#    anixe_hd             kabel1_doku          ric                  telezueri           
#    ard                  kabel-eins           rtl                  tlc                 
#    br                   kika                 rtl-2                toggo_plus          
#    br-alpha             kinowelt             rtlnitro             tv24                
#    channel_55           mdr-sachsen          rtl_plus             tv25                
#    comedycentral        n24_doku             s1                   vox                 
#    DE_arte              ndr-niedersachsen    sat1                 wdr-koeln           
#    de_sixx              nick                 sat1gold             weltderwunder       
#    disney               orf-1                servus_tv            zdf                 
#    dmax                 orf-2                sf-2                 zdf-info            
#    einsextra            phoenix              sf-info              zdfneo              
#    einsfestival         planet               sr-fernsehen                             
#    eotv                 pro7maxx             startv                                   
#   
: ${EMAIL="enkilo@gmx.ch"}
: ${PASSWORD="lalala"}
: ${PLAYER="mplayer"}

if [ -z "$1" ] ; then
  grep '^#  ' "$0" | sed "s|[ #]\+|\n|g" | grep . | sort -fu | column -c $(tput cols)
  exit 1
fi

exec streamlink  \
  --zattoo-email "$EMAIL" \
  --zattoo-password "$PASSWORD" \
  -p "$PLAYER" \
  https://zattoo.com/watch/"${1##*/}" ${2-1500k}
