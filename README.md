# rstatus

status_led.sh
Bash script for controlling status0 board for RaspberryPi0
Script displaying status of local nagios running on RaspberryPi

rrd_nagios_plugin.sh
Plugin for nagios for generating packet loss/latency graphs

command: create_rrd_latency_graph
Command line: /usr/local/bin/rrd_nagios_plugin.sh $HOSTADDRESS$ $ARG1$
ARG1 can be HDWMY

Create service in notes URL:
http://nagioshost/nagios3/images/rrd/latency_$HOSTADDRESS$.html

Alarm settings: all off
Max. check attempts: 1
Retry interval: NULL
Check Intervall NULL
