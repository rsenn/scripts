 browser-shortcuts() { (cd "$(cygpath -am "$USERPROFILE/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch")";
 
  for T in $(list-mediapath 'PortableApps/*'{Firefox,Chrome}'*/*'{irefox,hrome}'*.exe'); do D=$(dirname "$T"); DN=$(basename "$D"); mkshortcut -i "/cygdrive/d/Icons/ico/$DN.ico" -n "$DN" "$T"; done) 
  }

