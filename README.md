# rstatus

Work in progress...

Set of files to allow one command installation of nagios3/nagiosql on RaspberryPI0-W with (or without) Ststus board0

nagios.cfg - main nagios config

nagiosql.sql - initial database dump

nagios.yml - ansibple playbook for all packages/settings

settings.php - config file for nagiosql

timezone.php - php script for seting up timezone in php.ini

status_led.sh -
Bash script for controlling status0 board for RaspberryPi0
Script displaying status of local nagios running on RaspberryPi

rrd_nagios_plugin.sh -
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
