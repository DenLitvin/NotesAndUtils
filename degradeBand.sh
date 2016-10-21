#!/bin/bash
#https://www.coverfire.com/articles/queueing-in-the-linux-network-stack/

TC="/sbin/tc"

[ -e $TC ] || { echo "Failure: Netem is not available." ; exit 1; }

# get default network interface, usually "eth0"
DEV=$(/sbin/ip -4 route ls 2>&1 | grep default | grep -Po '(?<=dev )\S+')
[ -z "$DEV" ] && echo "Failure: could not detect default network interface" && exit 1

ADD="add dev $DEV"

saveIFS=$IFS
IFS='=&'
parm=($QUERY_STRING)
IFS=$saveIFS

for ((i=0; i<${#parm[@]}; i+=2))
do
    declare var_${parm[i]}=${parm[i+1]}
done

if [ "$var_output" != "compact" ]
then
    echo "Usage: curl \"http://$HOSTNAME:<port./cgi-bin/degradeBand.sh?hostId=1&hostIp=10.229.68.185&location=local&output=compact\""
    echo "hostId - used to set unique prio order for filters, hostIp ip adress, location: local or remote, output: compact for less text"
fi

if [[ $var_location == "local" ]]
then # forward colocated traffic to band 4
    $TC filter $ADD protocol ip parent 1:0 prio $var_hostId u32 match ip dst $var_hostIp/32 flowid 1:4 2>&1 || echo "ERROR: failed to set ip filter for host$hostId to local queue 1:4"
else # forward remote traffic to band 5
    $TC filter $ADD protocol ip parent 1:0 prio $var_hostId u32 match ip dst $var_hostIp/32 flowid 1:5 2>&1 || echo "ERROR: failed to set ip filter for host$hostId to remote queue 1:5"
fi

if [ "$var_output" != "compact" ]
then
    echo $HOSTNAME: new degrader state:
    $TC filter show dev eth0 2>&1
else
    echo "$HOSTNAME: ip filter to host$var_hostId succesfully set to $var_location queue."
fi


#$TC qdisc del dev $DEV root 2>&1

#$TC qdisc $ADD parent root handle 1: prio bands 6 2>&1

#if [[ $var_GRM1 ]]; then $TC qdisc $ADD parent 1:4 handle 40: netem delay $var_grm1delay"ms" 5ms 30% distribution paretonormal loss $var_grm1loss% 30% 2>&1; else echo "GRM1 not degraded missing IP"; fi
#if [[ $var_GRM1 ]]; then $TC filter $ADD protocol ip parent 1:0 prio 4 u32 match ip dst $var_GRM1/32 flowid 1:4 2>&1; fi

#$TC qdisc $ADD parent 1:5 handle 50: netem delay ${var[remoteDelay]}"ms" 5ms 30% distribution paretonormal loss ${var[remoteLoss]}% 30% 2>&1 || echo "ERROR: failed to attach degraded queue to 1:5 for remote traffic"


#$TC -d qdisc 2>&1
#$TC qdisc del dev $DEV root 2>&1
#$TC -d qdisc 2>&1
