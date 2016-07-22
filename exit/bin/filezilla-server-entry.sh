srv () 
{ 
    URL=${1%/}
    echo "            <Server>
                <Host>heanet.dl.sourceforge.net</Host>
                <Port>21</Port>
                <Protocol>0</Protocol>
                <Type>0</Type>
                <Logontype>0</Logontype>
                <TimezoneOffset>0</TimezoneOffset>
                <PasvMode>MODE_DEFAULT</PasvMode>
                <MaximumMultipleConnections>0</MaximumMultipleConnections>
                <EncodingType>Auto</EncodingType>
                <BypassProxy>0</BypassProxy>
                <Name>${URL##*/}</Name>
                <Comments />
                <LocalDir />
                <RemoteDir>$(srvsplit "$URL")</RemoteDir>
                <SyncBrowsing>0</SyncBrowsing>${URL##*/}
            </Server>"
}
srvsplit () 
{ 
    ( IFS="/ ";
    A=/${1#*://*/};
    set -- $A;
    OUT=;
    while [ $# -gt 0 ]; do
        N=${#1};
        OUT="${OUT:+$OUT }$N $1";
        shift;
    done;
    echo 1 $OUT )
}
