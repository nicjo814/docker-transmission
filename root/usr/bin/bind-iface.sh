#!/bin/bash

#Bind Transmission to interface specified by user.
#Only do this if AUTOBIND and BINDIFACE vars are set.
if [[ $AUTOBIND && $BINDIFACE ]]; then
    #Check that the interafce exists to prevent errors being thrown later
    IFACE_EXISTS=`ifconfig | grep "^$BINDIFACE[[:space:]]" | wc -l`
    if [ "$IFACE_EXISTS" -eq "1" ]; then
        #Get the current IP of the interface and check that the IP is set.
        IP=`ip -f inet -o addr show ${BINDIFACE}|cut -d\  -f 7 | cut -d/ -f 1`
        if [[ $IP ]]; then
            #Parse the settings.json file to get the IP transmission is currently bound to.
            OLD_IP=`grep bind-address-ipv4 settings.json`
            if [[ $OLD_IP =~ (^.*bind-address-ipv4\": \")(.*)\".*$ ]]; then
                OLD_IP=${BASH_REMATCH[2]}
                #Compare IP and OLD_IP and change settings.json only if they differ
                #First kill transmission-damon for settings change to take effect.
                if [ "$IP" != "$OLD_IP" ]; then
                    s6-svc -d /var/run/s6/services/transmission
                    killall -SIGKILL transmission-daemon
                    sed -i "s/\"bind-address-ipv4\": \(.*\)/\"bind-address-ipv4\": \"${IP}\",/g" /config/settings.json
                    s6-svc -u /var/run/s6/services/transmission
                    echo "Updated Transmission to listen on IP: $IP on interface: $BINDIFACE"
                fi
            fi
        fi
    fi
fi

