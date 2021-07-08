#!/bin/bash

#VAR
var001=$1
ipaddr=$( ip addr | grep 'inet ' | awk '{print $2}' | awk 'BEGIN {RS=""}{gsub(/\n/," ",$0); print $0}' | awk -F ' ' '{print $2}' | awk -F '/' '{print $1}' )
hostnamen="Hostname=$ipaddr"

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
            cd /tmp
            sudo wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb
            echo $iza
            sudo dpkg -i /tmp/zabbix-release_5.4-1+debian10_all.deb
            apt install zabbix-agent
        elif [ $( cat /etc/os-release | grep "_ID" | awk -F '"' '{print $2}' ) ==  "9" ]; then
            echo $isw && apt install sudo wget -y && echo $dza
            cd /tmp
            sudo wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian9_all.deb
            echo $iza
            sudo dpkg -i /tmp/zabbix-release_5.4-1+debian9_all.deb
            apt install zabbix-agent
        elif [ $( cat /etc/os-release | grep "_ID" | awk -F '"' '{print $2}' ) ==  "8" ]; then
            echo $isw && apt install sudo wget -y && echo $dza
            cd /tmp
            sudo wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian8_all.deb
            echo $iza
            sudo dpkg -i /tmp/zabbix-release_5.4-1+debian8_all.deb
            apt install zabbix-agent
        elif [ $( cat /etc/issue | grep Debian | awk -F ' ' '{print $3}' ) ==  "7.0" ]; then
            echo $isw && apt install sudo wget -y && echo $dza
            cd /tmp
            sudo wget  https://repo.zabbix.com/zabbix/2.0/debian/pool/main/z/zabbix-release/zabbix-release_2.0-1wheezy_all.deb
            echo $iza
            sudo dpkg -i /tmp/zabbix-release_2.0-1wheezy_all.deb
            apt install zabbix-agent
        elif [ $( cat /etc/issue | grep Debian | awk -F ' ' '{print $3}' ) ==  "6.0" ]; then
            echo $isw && apt install sudo wget -y && echo $dza
            cd /tmp
            sudo wget  https://repo.zabbix.com/zabbix/2.0/debian/pool/main/z/zabbix-release/zabbix-release_2.0-1squeeze_all.deb
            echo $iza
            sudo dpkg -i /tmp/zabbix-release_2.0-1squeeze_all.deb
            apt install zabbix-agent
        elif [ $( cat /etc/issue | grep Debian | awk -F ' ' '{print $3}' ) ==  "5.0" ]; then
            echo "version obsoleta"
        fi
    fi

    #if [ $( cat /etc/issue | grep Ubuntu | awk -F ' ' '{print $1}' ) ==  "Ubuntu" ]; then
    #    apt install sudo wget -y
    #    sudo wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+$(lsb_release -sc)_all.deb 
    #    sudo dpkg -i zabbix-release_5.0-1+$(lsb_release -sc)_all.deb
    #fi

    hostnameo=$( cat /etc/zabbix/zabbix_agentd.conf | grep -v "#" |grep "Hostname=" )
    zso=$( cat /etc/zabbix/zabbix_agentd.conf | grep -v "#" |grep "Server=" )
    zsao=$( cat /etc/zabbix/zabbix_agentd.conf | grep -v "#" |grep "ServerActive=" )
    zsn="Server="$var001
    zsan="ServerActive="$var001
    timeouto=$( cat /etc/zabbix/zabbix_agentd.conf | grep "Timeout=" )
    timeoutn="Timeout=30"

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
    rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release-5.4-1.el$(rpm -E %{rhel}).noarch.rpm
    yum clean all
    #rm -rf /var/cache/yum
    yum install zabbix-agent -y --skip-broken
    #sudo systemctl start zabbix-agent
    #sudo systemctl enable zabbix-agent

    hostnameo=$( cat /etc/zabbix/zabbix_agentd.conf | grep -v "#" |grep "Hostname=" )
    zso=$( cat /etc/zabbix/zabbix_agentd.conf | grep -v "#" |grep "Server=" )
    zsao=$( cat /etc/zabbix/zabbix_agentd.conf | grep -v "#" |grep "ServerActive=" )
    zsn="Server="$var001
    zsan="ServerActive="$var001
    timeouto=$( cat /etc/zabbix/zabbix_agentd.conf | grep "Timeout=" )
    timeoutn="Timeout=30"

    sed -i "s/$zso/$zsn/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/$zsao/$zsan/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/$hostnameo/$hostnamen/" /etc/zabbix/zabbix_agentd.conf
    service zabbix-agent start
    chkconfig zabbix-agent on
    service zabbix-agent restart
fi

if [ -x /usr/bin/zypper ]; then

    zypper addrepo https://download.opensuse.org/repositories/home:pclo:monitoring/openSUSE_Leap_$(cat /etc/os-release | grep VERSION= | awk -F "\"" '{print $2}')/home:pclo:monitoring.repo
    zypper refresh
    zypper install -y zabbix-agent 

    hostnameo=$( cat /etc/zabbix/zabbix-agentd.conf | grep -v "#" |grep "Hostname=" )
    zso=$( cat /etc/zabbix/zabbix-agentd.conf | grep -v "#" |grep "Server=" )
    zsao=$( cat /etc/zabbix/zabbix-agentd.conf | grep -v "#" |grep "ServerActive=" )
    zsn="Server="$var001
    zsan="ServerActive="$var001
    timeouto=$( cat /etc/zabbix/zabbix-agentd.conf | grep "Timeout=" )
    timeoutn="Timeout=30"

    sed -i "s/$zso/$zsn/" /etc/zabbix/zabbix-agentd.conf
    sed -i "s/$zsao/$zsan/" /etc/zabbix/zabbix-agentd.conf
    sed -i "s/$hostnameo/$hostnamen/" /etc/zabbix/zabbix-agentd.conf
    #service zabbix-agent start
    #chkconfig zabbix-agent on
    #service zabbix-agent restart
    rczabbix-agentd start
    chkconfig zabbix-agentd on
    rczabbix-agentd restart
fi