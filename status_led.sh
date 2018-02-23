#!/bin/bash

set -e



STATFILE="/var/cache/nagios3/status.dat"

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


st_led () {

#echo $1
#echo $2

if [ "$1" == "host" ];then
    Red=4
    Green=17
fi

if [ "$1" == "service" ];then
    Red=27
    Green=22
fi

if [ "$1" == "local" ];then
    Red=10
    Green=9
fi

	gpio mode ${Red} out
	gpio mode ${Green} out

	if [ "$2" = "OK" ];then
	    gpio write ${Red} 0
	    gpio write ${Green} 1
	fi

	if [ "$2" = "WA" ];then
	    gpio write ${Red} 1
	    gpio write ${Green} 1
	fi

	if [ "$2" = "CR" ];then
	    gpio write ${Red} 1
	    gpio write ${Green} 0
	fi

}


get_localstatus () {

	ps ax | grep -v grep | grep nagios3 > /dev/null 2>&1; NAGIOS=$?
	ls /var/cache/nagios3/status.dat > /dev/null 2>&1 ; FILE=$?
	/sbin/iwconfig wlan0 | grep "ESSID:\"WhiteyWireless\""  > /dev/null 2>&1 ; WIFI=$?

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


	if [[ "${NAGIOS}" -ge "0" ]] || [[ "${FILE}" -ge "0" ]] || [[ "${WIFI}" -ge "0" ]] | [[ "${DISK}" -ge "0" ]] || [[ "${TEMP}" -ge "0" ]]; then
	    #localstatus=OK
	    #echo localstatus OK
	    st_led local OK
	else
	    #localstatus=CR
	    #echo localstatus CR
	    st_led local CR
	fi

}



get_status () {
    #STAT=`cat ${STATFILE} | grep -v "#"| awk '{printf("%s",$1)}'|awk -F"${1}status" '{i=2;while(i<=NF){print $i;i++}}' | grep "current_state=${2}" | wc -l`
    STATCR=`cat ${STATFILE} | grep -v "#"| awk '{printf("%s",$1)}'|awk -F"${1}status" '{i=2;while(i<=NF){print $i;i++}}' | grep "current_state=2" | wc -l`
    STATWA=`cat ${STATFILE} | grep -v "#"| awk '{printf("%s",$1)}'|awk -F"${1}status" '{i=2;while(i<=NF){print $i;i++}}' | grep "current_state=1" | wc -l`

#echo ${STATCR} $1
#echo ${STATWA} $1

if [ "${STATCR}" -ge "1" ];then
    #echo ${1}status CR
    st_led $1 CR
elif [ "${STATWA}" -ge "1" ];then
    #echo ${1}status WA
    st_led $1 WA
else
    #echo ${1}status OK
    st_led $1 OK
fi

}


get_status host
get_status service
get_localstatus

























