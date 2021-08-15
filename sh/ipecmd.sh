#!/bin/sh
MPLABX_DIR=/opt/microchip/mplabx/v5.50
    
exec env jdkhome=/opt/microchip/mplabx/v5.50/sys/java/zulu8.40.0.25-ca-fx-jre8.0.222-linux_x64 sh $MPLABX_DIR/mplab_platform/mplab_ipe/ipecmd.sh "$@"
