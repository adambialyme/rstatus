#!/bin/bash

# --------------------------------------------------------------
# In nagios specify command:
# /usr/local/bin/rrd_allinone.sh $HOSTADDRESS$ $ARG1$
# ARG one can be any of the letters HDWMY
# (Hourly, Daily, Weekly, Monthly, Yearly)
# If not specified only Daily and Weekly will be generated
# --------------------------------------------------------------

if [ "$1" == "" ];then
    echo "please specify target"
    exit 1;
fi

# --------------------------------------------------------------
#  set the paths
# --------------------------------------------------------------
PING=`which ping`
RRDTOOL=`which rrdtool`
DBPATH="/var/spool/rrddb/"
NAGIOSPATH="/usr/share/nagios3/htdocs/images/rrd/"
GRHEIGHT="150"
GRWIDTH="600"
COUNT=4
DEADLINE=10
PINGHOST=$1
GRAPHS=$2
# --------------------------------------------------------------

# --------------------------------------------------------------
# set graphs to daily and weekly if not specified
# --------------------------------------------------------------
if [ "${GRAPHS}" == "" ];then
    GRAPHS=DW
fi
# --------------------------------------------------------------


# --------------------------------------------------------------
#  initiate db if doesn't exist
# --------------------------------------------------------------
if [ ! -f "${DBPATH}latency_db_$1.rrd" ];then
    cd ${DBPATH}

${RRDTOOL} create ${DBPATH}/latency_db_$1.rrd \
--step 300 \
DS:pl:GAUGE:600:0:100 \
DS:rtt:GAUGE:600:0:10000000 \
RRA:AVERAGE:0.5:1:800 \
RRA:AVERAGE:0.5:6:800 \
RRA:AVERAGE:0.5:24:800 \
RRA:AVERAGE:0.5:288:800 \
RRA:MAX:0.5:1:800 \
RRA:MAX:0.5:6:800 \
RRA:MAX:0.5:24:800 \
RRA:MAX:0.5:288:800
exit 0;
fi
# --------------------------------------------------------------


function GEN_HTML {
echo -e "<html><head><title>Latency and packet loss for host ${PINGHOST}</title></head><body><div id="\""wrapper"\"" style="\""width:100%; text-align:center"\""><br />" > ${NAGIOSPATH}latency_${PINGHOST}.html
	for I in H D W M Y; do
		if [[ ${GRAPHS} == *${I}* ]];then
		    echo "<img src="\""latency_${I}_${PINGHOST}.png"\"" /><br /><br />" >> ${NAGIOSPATH}latency_${PINGHOST}.html
		fi
	done
echo "</div></body></html>" >> ${NAGIOSPATH}latency_${PINGHOST}.html
}



ping_host() {
local output=$(${PING} -q -n -c $COUNT -w ${DEADLINE} $1 2>&1)
# notice $output is quoted to preserve newlines
local temp=$(echo "$output"| awk '
BEGIN {pl=100; rtt=0.1}
/packets transmitted/ {
match($0, /([0-9]+)% packet loss/, matchstr)
pl=matchstr[1]
}
/^rtt/ {
# looking for something like 0.562/0.566/0.571/0.024
match($4, /(.*)\/(.*)\/(.*)\/(.*)/, a)
rtt=a[2]
}
/unknown host/ {
# no output at all means network is probably down
pl=100
rtt=0.1
}
END {print pl ":" rtt}
')
RETURN_VALUE=$temp
}
# ping a host on the local lan
ping_host $1
${RRDTOOL} update \
${DBPATH}/latency_db_$1.rrd \
--template \
pl:rtt \
N:$RETURN_VALUE


function GEN_GRAPH {
cd ${DBPATH}


if [ "${2}" == "H" ];then
    GRSTART="3600"
    GREND="60"
    XGRID="--x-grid MINUTE:10:HOUR:1:MINUTE:30:0:%R"
fi

if [ "${2}" == "D" ];then
    GRSTART="86400"
    GREND="60"
    XGRID="--x-grid MINUTE:30:HOUR:1:HOUR:2:0:%H"
fi

if [ "${2}" == "W" ];then
    GRSTART="604800"
    GREND="1800"
    XGRID="--x-grid MINUTE:360:HOUR:6:HOUR:12:0:%H"
fi

if [ "${2}" == "M" ];then
    GRSTART="2592000"
    GREND="7200"
fi

if [ "${2}" == "Y" ];then
    GRSTART="31536000"
    GREND="86400"
fi


${RRDTOOL} graph ${NAGIOSPATH}latency_${2}_${1}.png -h ${GRHEIGHT} -w ${GRWIDTH} -a PNG \
--lazy --start -${GRSTART} --end -${GREND} \
${XGRID} -v "Round-Trip Time (ms)" \
--rigid \
--lower-limit 0 \
DEF:roundtrip=latency_db_$1.rrd:rtt:AVERAGE \
DEF:packetloss=latency_db_$1.rrd:pl:AVERAGE \
CDEF:PLNone=packetloss,0,2,LIMIT,UN,UNKN,INF,IF \
CDEF:PL2=packetloss,2,8,LIMIT,UN,UNKN,INF,IF \
CDEF:PL15=packetloss,8,15,LIMIT,UN,UNKN,INF,IF \
CDEF:PL25=packetloss,15,25,LIMIT,UN,UNKN,INF,IF \
CDEF:PL50=packetloss,25,50,LIMIT,UN,UNKN,INF,IF \
CDEF:PL75=packetloss,50,75,LIMIT,UN,UNKN,INF,IF \
CDEF:PL100=packetloss,75,100,LIMIT,UN,UNKN,INF,IF \
AREA:roundtrip#4444ff:"Round Trip Time (millis)" \
GPRINT:roundtrip:LAST:"Cur\: %5.2lf" \
GPRINT:roundtrip:AVERAGE:"Avg\: %5.2lf" \
GPRINT:roundtrip:MAX:"Max\: %5.2lf" \
GPRINT:roundtrip:MIN:"Min\: %5.2lf\n" \
AREA:PLNone#6c9bcd:"0-2%":STACK \
AREA:PL2#00ffae:"2-8%":STACK \
AREA:PL15#ccff00:"8-15%":STACK \
AREA:PL25#ffff00:"15-25%":STACK \
AREA:PL50#ffcc66:"25-50%":STACK \
AREA:PL75#ff9900:"50-75%":STACK \
AREA:PL100#ff0000:"75-100%":STACK \
COMMENT:"(Packet Loss Percentage)" > /dev/null 2>&1
}


GEN_HTML

for I in H D W M Y; do
	if [[ ${GRAPHS} == *${I}* ]];then
	    GEN_GRAPH ${PINGHOST} ${I}
	fi
done

# --------------------------------------------------------------
# return OK value as the probe is only for graphing
echo "OK - Packet Loss: `echo $RETURN_VALUE | awk -F: {'print $1'}`%; Latency: `echo $RETURN_VALUE | awk -F: {'print $2'}`ms "; exit 0;
# --------------------------------------------------------------

