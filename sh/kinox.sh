#!/bin/sh
# Get stream URLs for the second episode of the seventh season of futurama:
# kinox.sh futurama 7 2
# for shows with spaces, insert a plus sign instead:
# kinox.sh it+crowd 3 1

# grab the stream by searching for the show on kinox.to, filtering to only show english versions, and extracting the internal show name
export stream_page=$(curl -sL "http://kinox.to/Search.html?q=$1" | pcregrep -M 'lng\/2\.png(\n|.)+?class="Title"' | pcregrep -o1 'Stream\/(.+?)\.html' | head -n 1)

# get the show's page, with the undocumented additional parameters for season and episode, and grab the "rel" attribute of the hoster list
export stream_rel=$(curl -sL http://kinox.to/Stream/$stream_page.html,s$2e$3 |grep rel= | pcregrep -o1 '<li i.+?rel="(.+?)"' | perl -pe 's/&amp;/&/g')

# for every rel attribute (which will contain season, episode, hoster id and mirror id)
while read -r line; do
    # call the "secret" API. This will yield a JSON object, but since we're only interested in one attribute, we'll throw some regex on top and print the list of stream urls
    curl -sL "http://kinox.to/aGET/Mirror/$line" | pcregrep -o1 'map> <a href=\\"(.+?)\\"' | tr -d '\' |perl -pe 's/\/Out\/\?s=//g'
done <<< "$stream_rel"
