#!/bin/bash


function genpass {
MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

while [ "${n:=1}" -le "10" ]
do
    PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
    let n+=1
done
echo "$PASS"
}

function saltpass {
echo $1 | mkpasswd --method=sha-512 --password-fd=0
}



#echo "change pass for pi"
#read PI_PASSWD
#SALTPI_PASSWD=$(saltpass ${PI_PASSWD})
#echo ${SALTPI_PASSWD}



#echo "All passwords at the end will be stored in text file: /home/pi/rstatus_passwords.txt"
#
#echo "Type root database password. (or press [ENTER] to generate one)"
#read ROOT_DBPASSWD
#if [ "${ROOT_DBPASSWD}" == "" ]; then ROOT_DBPASSWD=$(genpass);fi

#echo "Type NagiosQL database password. (or press [ENTER] to generate one)"
#read NQL_DBPASSWD
#if [ "${NQL_DBPASSWD}" == "" ]; then NQL_DBPASSWD=$(genpass) ;fi

#echo "Type nagios web interface user. (or press [ENTER] to use 'nagiosadmin')"
#read NG_USER
#if [ "${NG_USER}" == "" ]; then NG_USER=nagiosadmin ;fi

#echo "Type nagios web interface user. (or press [ENTER] to generate one)"
#read NG_PASSWD
#if [ "${NG_PASSWD}" == "" ]; then NG_PASSWD=$(genpass);fi

if [ "$1" = "dbpass" ]; then
genpass
echo "dbpass: ${PASS}" > ~/.rstatus_dbpass.txt
fi

if [ "$1" = "nagiospass" ]; then
genpass
echo "nagiospass: ${PASS}" > ~/.rstatus_nagiospass.txt
fi

if [ "$1" = "nagiosqlpass" ]; then
genpass
echo "nagiosqlpass: ${PASS}" > ~/.rstatus_nagiosqlpass.txt
fi

