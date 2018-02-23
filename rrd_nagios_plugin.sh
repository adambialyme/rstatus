#!/bin/bash

# Utility to control the GPIO pins of the Raspberry Pi
# Can be called as a script or sourced so that the gpio
# function can be called directly
#
# led numbers:
# row	col	gpipno
# 1	red	4
# 	green	17
#
# 2	red	27
# 	green	22
#
# 3	red	10
# 	green	9



function gpio()
{
    local verb=$1
    local pin=$2
    local value=$3

    local pins=($GPIO_PINS)
    if [[ "$pin" -lt ${#pins[@]} ]]; then
        local pin=${pins[$pin]}
    fi

    local gpio_path=/sys/class/gpio
    local pin_path=$gpio_path/gpio$pin

    case $verb in
        read)
            cat $pin_path/value
        ;;

        write)
            echo $value > $pin_path/value
        ;;

        mode)
            if [ ! -e $pin_path ]; then
                echo $pin > $gpio_path/export
            fi
            echo $value > $pin_path/direction
        ;;

        state)
            if [ -e $pin_path ]; then
                local dir=$(cat $pin_path/direction)
                local val=$(cat $pin_path/value)
                echo "$dir $val"
            fi
        ;;
    esac
}


STATFILE="/var/cache/nagios3/status.dat"

get_status () {
	    STAT=`cat ${STATFILE} | grep -v "#"| awk '{printf("%s",$1)}'|awk -F"${1}status" '{i=2;while(i<=NF){print $i;i++}}' | grep "current_state=${2}" | wc -l`
	    eval ${1}status${2}="${STAT}"
}

get_localstatus () {

#	    STAT=`cat ${STATFILE} | grep -v "#"| awk '{printf("%s",$1)}'|awk -F"${1}status" '{i=2;while(i<=NF){print $i;i++}}' | grep "current_state=${2}" | wc -l`
#	    eval ${1}status${2}="${STAT}"

	NAGIOS=`ps ax | grep nagios3 | grep -v grep | wc -l`

	if [ -e  /var/cache/nagios3/status.dat ]; then
	    FILE=1
	fi

	WIFI=`iwconfig 2>&1 | grep "ESSID:\"WhiteyWireless\"" | wc -l`

	if [ "`df --output=pcent / | tail -n 1 | tr -d \%`" -ge "98" ];then
	    DISK=1
	else
	    DISK=0
	fi

	if [ "`cat /sys/class/thermal/thermal_zone0/temp`" -ge "45000" ];then
	    TEMP=1
	else
	    TEMP=0
	fi

	LOCALSUM=$((${NAGIOS}+${FILE}+${WIFI}+${DISK}+${TEMP}))

	if [ "${LOCALSUM}" = "0" ];then
	    OK
	else
	    CR
	fi

}



kill_led () {
kill -9 `ps ax | grep "led.sh $1" | grep -v grep | awk {'print $1'}`
}


#while true; do

get_status host 2
get_status host 1

get_status service 2
get_status service 1

get_status localservice 2
get_status localservice 1

#echo $servicestatus1
#echo $servicestatus2
#echo $hoststatus1
#echo $hoststatus2


ledhost=OK
ledservice=OK

if [ ${hoststatus1} -ge 1 ];then
    ledhost=WA
fi

if [ ${hoststatus2} -ge 1 ];then
    ledhost=CR
fi

if [ ${servicestatus1} -ge 1 ];then
    ledservice=WA
fi

if [ ${servicestatus2} -ge 1 ];then
    ledservice=CR
fi

kill_led 1

if [ "${ledhost}" = "OK" ];then
    ./led.sh 1 OK &
fi

if [ "${ledhost}" = "WA" ];then
    ./led.sh 1 WA &
fi

if [ "${ledhost}" = "CR" ];then
    ./led.sh 1 CR &
fi

kill_led 2

if [ "${ledservice}" = "OK" ];then
    ./led.sh 2 OK &
fi

if [ "${ledservice}" = "WA" ];then
    ./led.sh 2 WA &
fi

if [ "${ledservice}" = "CR" ];then
    ./led.sh 2 CR &
fi

#sleep 20
#done 


#cat ${STATFILE} | grep -v "#"| awk '{printf("%s",$1)}'|awk -F"servicestatus" '{i=2;while(i<=NF){print $i;i++}}' | grep "current_state=1" | wc -l
#cat ${STATFILE} | grep -v "#"| awk '{printf("%s",$1)}'|awk -F"servicestatus" '{i=2;while(i<=NF){print $i;i++}}' | grep "current_state=2" | wc -l
#
#cat ${STATFILE} | grep -v "#"| awk '{printf("%s",$1)}'|awk -F"hoststatus" '{i=2;while(i<=NF){print $i;i++}}' | grep "current_state=1" | wc -l
#cat ${STATFILE} | grep -v "#"| awk '{printf("%s",$1)}'|awk -F"hoststatus" '{i=2;while(i<=NF){print $i;i++}}' | grep "current_state=2" | wc -l

# https://luketopia.net/2013/07/28/raspberry-pi-gpio-via-the-shell/


#if [[ "${PERC}" -lt "${WARN}" ]]; then
#echo "OK - ${LABEL}; USED: ${PERC}%"
#exit 0;
#fi


#if [[ "${PERC}" -ge "${WARN}" ]] && [[ "${PERC}" -lt "${CRIT}" ]]; then
#echo "WARNING - ${LABEL}; USED: ${PERC}%"
#exit 1;
#fi


#if [[ "${PERC}" -ge "${CRIT}" ]]; then
#echo "CRITICAL - ${LABEL}; USED: ${PERC}%"
#exit 2;
#fi



source /usr/local/bin/gpio
#gpio mode 17 out
#gpio mode 4 out
#gpio mode 22 out
#gpio mode 27 out
#gpio mode 9 out
#gpio mode 10 out

if [ "$1" = "1" ];then
    while true; do
    gpio mode 17 out
    gpio mode 4 out

    if [ "$2" = "OK" ];then
	gpio write 4 0
	gpio write 17 1
	sleep 10
    fi

    if [ "$2" = "WA" ];then
	gpio write 4 1
        gpio write 17 1
	sleep 10
    fi

    if [ "$2" = "CR" ];then
	gpio write 17 0
        gpio write 4 1
	sleep 10
    fi


#    gpio write 4 1
#    sleep 0.1
#    gpio write 4 0
#    sleep 0.1
#
#    gpio write 17 1
#    sleep 0.1
#    gpio write 17 0
#    sleep 0.1

    done
fi

if [ "$1" = "2" ];then
while true; do
    gpio mode 22 out
    gpio mode 27 out


    if [ "$2" = "OK" ];then
	gpio write 22 1
        gpio write 27 0
	sleep 10
    fi

    if [ "$2" = "WA" ];then
	gpio write 22 1
        gpio write 27 1
#	sleep 0.1
#	gpio write 27 0
#	#sleep 10
#	sleep 0.6
	sleep 10
    fi

    if [ "$2" = "CR" ];then
	gpio write 22 0
        gpio write 27 1
	sleep 10
    fi


#    gpio write 27 1
#    sleep 0.1
#    gpio write 27 0
#    sleep 0.1
#
#    gpio write 22 1
#    sleep 0.1
#    gpio write 22 0
#    sleep 0.1

done
fi

if [ "$1" = "3" ];then
while true; do
gpio mode 9 out
gpio mode 10 out


    if [ "$2" = "OK" ];then
	gpio write 9 1
        gpio write 10 0
	sleep 10
    fi

    if [ "$2" = "WA" ];then
	gpio write 9 1
	sleep 0.1
	gpio write 9 0
	#sleep 10
	sleep 0.3
    fi

    if [ "$2" = "CR" ];then
	gpio write 9 0
        gpio write 10 1
	sleep 10
    fi


#    gpio write 10 1
#    sleep 0.1
#    gpio write 10 0
#    sleep 0.1
#
#    gpio write 9 1
#    sleep 0.1
#    gpio write 9 0
#    sleep 0.1
done  
fi


##!/usr/bin/env python