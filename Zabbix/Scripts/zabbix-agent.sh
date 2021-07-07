#!/bin/bash

#VAR
var001=$1
ipaddr=$( ip addr | grep 'inet ' | awk '{print $2}' | awk 'BEGIN {RS=""}{gsub(/\n/," ",$0); print $0}' | awk -F ' ' '{print $2}' | awk -F '/' '{print $1}' )
hostnamen="Hostname=$ipaddr"
hostnameo=$( cat /etc/zabbix/zabbix_agentd.conf | grep -v "#" |grep "Hostname=" )
zso=$( cat /etc/zabbix/zabbix_agentd.conf | grep -v "#" |grep "Server=" )
zsao=$( cat /etc/zabbix/zabbix_agentd.conf | grep -v "#" |grep "ServerActive=" )
zsn="Server="$var001
zsan="ServerActive="$var001
timeouto=$( cat /etc/zabbix/zabbix_agentd.conf | grep "Timeout=" )
timeoutn="Timeout=30"
isw="\n########################################\nInstalando sudo + wget\n\n"
dza="\n########################################\nDescargando zabbix-agent\n\n"
iza="\n########################################\nInstalando zabbix-agent\n\n"

if [ "$UID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Only run it if we can (ie. on Ubuntu/Debian)
if [ -x /usr/bin/apt-get ]; then

    if [ $( cat /etc/issue | grep Debian | awk -F ' ' '{print $1}' ) ==  "Debian" ]; then
        if [ $( cat /etc/os-release | grep "_ID" | awk -F '"' '{print $2}' ) ==  "10" ]; then
            echo $isw && apt install sudo wget -y && echo $dza
            sudo wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb
            echo $iza
            sudo dpkg -i zabbix-release_5.4-1+debian10_all.deb
        elif [ $( cat /etc/os-release | grep "_ID" | awk -F '"' '{print $2}' ) ==  "9" ]; then
            echo $isw && apt install sudo wget -y && echo $dza
            sudo wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian9_all.deb
            echo $iza
            sudo dpkg -i zabbix-release_5.4-1+debian9_all.deb
        elif [ $( cat /etc/os-release | grep "_ID" | awk -F '"' '{print $2}' ) ==  "8" ]; then
            echo $isw && apt install sudo wget -y && echo $dza
            sudo wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian8_all.deb
            echo $iza
            sudo dpkg -i zabbix-release_5.4-1+debian8_all.deb
        elif [ $( cat /etc/issue | grep Debian | awk -F ' ' '{print $3}' ) ==  "7.0" ]; then
            echo $isw && apt install sudo wget -y && echo $dza
            sudo wget  https://repo.zabbix.com/zabbix/2.0/debian/pool/main/z/zabbix-release/zabbix-release_2.0-1wheezy_all.deb
            echo $iza
            sudo dpkg -i zabbix-release_2.0-1wheezy_all.deb
        elif [ $( cat /etc/issue | grep Debian | awk -F ' ' '{print $3}' ) ==  "6.0" ]; then
            echo $isw && apt install sudo wget -y && echo $dza
            sudo wget  https://repo.zabbix.com/zabbix/2.0/debian/pool/main/z/zabbix-release/zabbix-release_2.0-1squeeze_all.deb
            echo $iza
            sudo dpkg -i zabbix-release_2.0-1squeeze_all.deb
        elif [ $( cat /etc/issue | grep Debian | awk -F ' ' '{print $3}' ) ==  "5.0" ]; then
            echo "version obsoleta"
        fi
    fi

    #if [ $( cat /etc/issue | grep Ubuntu | awk -F ' ' '{print $1}' ) ==  "Ubuntu" ]; then
    #    apt install sudo wget -y
    #    sudo wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+$(lsb_release -sc)_all.deb 
    #    sudo dpkg -i zabbix-release_5.0-1+$(lsb_release -sc)_all.deb
    #fi

    sudo systemctl enable zabbix-agent
    sed -i "s/$zso/$zsn/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/$zsao/$zsan/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/$hostnameo/$hostnamen/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/$timeouto/$timeoutn/" /etc/zabbix/zabbix_agentd.conf
    service zabbix-agent start
    service zabbix-agent restart


fi

# Only run it if we can (ie. on RHEL/CentOS)
if [ -x /usr/bin/yum ]; then
    rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release-5.0-1.el$(rpm -E %{rhel}).noarch.rpm
    sudo systemctl start zabbix-agent
    sudo systemctl enable zabbix-agent
    sed -i "s/$zso/$zsn/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/$zsao/$zsan/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/$hostnameo/$hostnamen/" /etc/zabbix/zabbix_agentd.conf
    service zabbix-agent restart
fi