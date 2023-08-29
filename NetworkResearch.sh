#!/bin/bash

#Name: Sapir Segev,
#Class code: 7736/13
#Lecturer's name: Adonis Azzam


#checking to see if the user is root

if [ $(id -u) -ne 0 ]
then
	echo "This script must be ran as root"
	exit 
fi

#checking to see if the following applications are installed: anonsurf, sshpass, geoiplookup

function checkinstall () {
	echo "checking if the following application is installed: sshpass"
	sleep 2
	sshpasscheck=$(dpkg -s sshpass 2> /dev/null)
	
	if [[ -z $sshpasscheck ]]
	then 
		echo "sshpass is not installed, installing"
		apt-get install sshpass -y

	else
		echo "sshpass is already installed"
	fi

	echo "checking if the following application is installed: anonsurf"
	sleep 2
	anoncheck=$(dpkg -s kali-anonsurf 2> /dev/null)
	
	if [[ -z $anoncheck ]]
	then
		echo "anonsurf is not installed, installing"
		git clone https://github.com/Und3rf10w/kali-anonsurf.git && cd kali-anonsurf && bash installer.sh
	else
		echo "anonsurf is already installed, proceeding"
	fi

	echo "checking if the following application is installed: Geoiplookup"
	sleep 2
	geoipcheck=$(dpkg -s geoip-bin 2>/dev/null)
	
	if [[ -z $geoipcheck ]]
	then
		echo "geoiplookup is not installed,installing"
		apt-get install geoip-bin -y
	else
		echo "geoiplookup is already installed"
	fi
}

checkinstall

#checking to see if the user's network connection is anonymous, if not, alert the user and exit

function exe_anonsurf () {
	echo "checking if the network connection is anonymous"
	sleep 2
	anonsurf start
	country=$(geoiplookup $(curl -s ifconfig.me) | awk '{print $4}' | sed 's/,//g')

	if [ $country != IL ]
	then 
		echo "user is anonymous"
		echo "$country"
	else
		echo "user is not anonymous"
		exit
	fi
}
exe_anonsurf


#Allows the user to specify the domain/IP Address as a variable

function domain_ip () {
	while true
	do
		echo "Type a Domain/IP Address"
		read x
		if ! [ -z $x ];then
		ipaddr="$x"
		break;fi
	done
}
ipaddr=""

domain_ip

#Displays the details of the remote server (country, IP, and uptime), and returns the whois and open ports inputs of the given address, and saves the data into a file on the local computer, creates a log and audits the collected data
  function ssh_connect () {
	  
	  sshpass -p kali ssh kali@192.168.30.128 "geoiplookup $(curl -s ifconfig.me)"
	  sshpass -p kali ssh kali@192.168.30.128 "curl -s ifconfig.me"
	  sshpass -p kali ssh kali@192.168.30.128 "uptime"
	  sshpass -p kali ssh kali@192.168.30.128 "whois $ipaddr" >> whoisdata
	  echo "$(date) whois data collected for $ipaddr" >>nr.log 
	  sshpass -p kali ssh kali@192.168.30.128 "nmap $ipaddr" >> nmapdata
	  echo "$(date) nmap data collected for $ipaddr" >>nr.log
  }
  ssh_connect
