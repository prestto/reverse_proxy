#! /bin/bash

HOST_IP="192.168.1.22"

function check_hosts {
    echo "Expecting host $HOST_IP to be in /etc/hosts"

    HOSTS=$(cat /etc/hosts | grep $HOST_IP)

    if [[ $HOSTS ]]
    then
        echo "/etc/hosts looks to be correctly configured"
    else
        echo "Host $HOST_IP not found in /etc/hosts, this is necessary for DNS to work"
        echo "Add the following line to /etc/hosts :"
        echo "$HOST_IP    gitlab.dali.dev openproject.dali.dev dali.dev"
        echo "This can probable be done using the command:"
        echo "    sudo bash -c \"echo '$HOST_IP    gitlab.dali.dev openproject.dali.dev dali.dev\' >> /etc/hosts\""
        exit 1
    fi
}

function kill80 {
    PROCESSES=$(sudo lsof -t -i tcp:80 -s tcp:listen)
    
    if [[ $PROCESSES ]]
    then
        echo "killing processes:"
        echo $PROCESSES
        sudo xargs kill $PROCESSES
    else
        echo "nothing to kill"
    fi
}

function run_dev {
    docker-compose up
}

function usage {
        echo "Usage: $0 <ACTION>"
        echo "Parameters :"
        echo " - ACTION values :"
        echo "   * dev                            - Launching dev environment."
        echo "   * kill80                         - Kill process running on port 80."
}

# Checking parameters and Env
if [[ "$1" == "" ]]; then
   echo "Missing arguments."
   usage
   exit 1
fi

# make squre that hosts are correctly configured
check_hosts

case "$1" in

        dev)
            run_dev
            ;;
        
        kill80)
            echo "Killing processes on port 80."
            kill80
            ;;

        *)
            echo "Invalid environment detected (${1})"
            usage
            exit 1
            ;;
esac
