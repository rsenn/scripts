filezilla_server() { 
 (. require.sh
  require web/sourceforge
  for ARG in "$@"; do

    URL=$(sourceforge_url "$ARG" download)
    URL=${URL%/}
    HOST=${URL#*://}
    HOST=${HOST%%/*}
    LOCATION=${URL#*$HOST}

    NAME=${URL##*/};
    cat <<EOF
    <Server>
      <Host>${HOST}</Host>
      <Port>21</Port>
      <Protocol>0</Protocol>
      <Type>0</Type>
      <Logontype>0</Logontype>
      <TimezoneOffset>0</TimezoneOffset>
      <PasvMode>MODE_DEFAULT</PasvMode>
      <MaximumMultipleConnections>0</MaximumMultipleConnections>
      <EncodingType>Auto</EncodingType>
      <BypassProxy>0</BypassProxy>
      <Name>${NAME}</Name>
      <Comments />
      <LocalDir />
      <RemoteDir>$(filezilla_location "$LOCATION")</RemoteDir>
      <SyncBrowsing>0</SyncBrowsing>
      <DirectoryComparison>
      0</DirectoryComparison>${NAME}
    </Server>
EOF
  done)
}
