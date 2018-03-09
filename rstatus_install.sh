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


#echo -e " root db password: ${ROOT_DBPASSWD}\n nagios sql password: ${NQL_DBPASSWD}\n nagios user: ${NG_USER}\n nagios password${NG_PASSWD}"




exit 0;


sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install ansible mc git python-mysqldb -y

git clone https://github.com/adambialyme/rstatus.git

cd rstatus


