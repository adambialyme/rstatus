#!/bin/bash

# Bash script to control LEDs
# based on nagios status
#
# red		4
# yellow	18
# green		24


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

    esac
}



function blink () {
	gpio mode $1 out
	gpio write $1 $2
}


#blink $1 $2

function disco () {
for (( ; ; ))
do
	blink 4 0
	sleep 0.2
	blink 4 1
	sleep 0.2
	blink 18 0
	sleep 0.2
	blink 18 1
	sleep 0.2
	blink 24 0
	sleep 0.2
	blink 24 1
	sleep 0.2
done
}

disco

