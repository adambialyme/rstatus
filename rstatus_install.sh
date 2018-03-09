#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install ansible mc git python-mysqldb -y

git clone https://github.com/adambialyme/rstatus.git

cd rstatus


