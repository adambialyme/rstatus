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


echo "change pass for pi"
read PI_PASSWD
SALTPI_PASSWD=$(saltpass ${PI_PASSWD})
echo ${SALTPI_PASSWD}


echo "All passwords at the end will be stored in text file: /home/pi/rstatus_passwords.txt"

echo "Type root database password. (or press [ENTER] to generate one)"
read ROOT_DBPASSWD
if [ "${ROOT_DBPASSWD}" == "" ]; then ROOT_DBPASSWD=$(genpass);fi

echo "Type NagiosQL database password. (or press [ENTER] to generate one)"
read NQL_DBPASSWD
if [ "${NQL_DBPASSWD}" == "" ]; then NQL_DBPASSWD=$(genpass) ;fi

echo "Type nagios web interface user. (or press [ENTER] to use 'nagiosadmin')"
read NG_USER
if [ "${NG_USER}" == "" ]; then NG_USER=nagiosadmin ;fi

echo "Type nagios web interface user. (or press [ENTER] to generate one)"
read NG_PASSWD
if [ "${NG_PASSWD}" == "" ]; then NG_PASSWD=$(genpass);fi


echo -e " root db password: ${ROOT_DBPASSWD}\n nagios sql password: ${NQL_DBPASSWD}\n nagios user: ${NG_USER}\n nagios password${NG_PASSWD}">/home/pi/rstatus_passwords.txt


echo "Do you want to configure msmtp (lightweigt smtp client) for nagios messaging (y/n)"
read MSMTP_CHOICE
if [ "${MSMTP_CHOICE}" == "" ] || [ "${MSMTP_CHOICE}" == "y" ]; then configure_msmtp;fi

#exit 0;


sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install ansible git -y

git clone https://github.com/adambialyme/rstatus.git

cd rstatus

ansible -K -l localhost nagios.yml


