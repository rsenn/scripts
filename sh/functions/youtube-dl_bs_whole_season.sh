youtube-dl_bs_whole_season() {
  youtube-dl-launcher.sh $(for f in \
  $(wget -q -O - "$@" | grep -i streamcloud-1 | perl -pe 's/.*href=\"/http:\/\/bs.to\//g;s/-1\"(.*)/-1/g;'); do \
    wget -q -O - ${f} | grep -i 'link zum orig' | perl -pe 's/.*http(.*).html.*/http$1.html/g;';\
    done) 
}
