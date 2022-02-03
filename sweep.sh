#!/usr/bin/env bash

netcat(){
  for sub_address in {1..254}; do
    nc -vzw 1 $1.$sub_address $2 | grep -B 1 'succeeded!' &
    killall nc 2>/dev/null
  done
}

netcat_range(){
  for (( c=$1; c<=$2; c++ )); do
    nc -vzw 1 $3.$c $4 | grep -B 1 'succeeded!' &
    killall nc 2>/dev/null
  done
}


# Ping sweep Module
pingsweep(){
  for sub_address in {1..254}; do
    ping -c 1 $1.$sub_address | grep -B 1 "1 received" | grep -E -o '([0-9]{1,3}[\.]){3}([0-9]{1,3})' &
    killall ping 2>/dev/null
  done
}

pingsweep_range(){
  for (( c=$1; c<=$2; c++ )); do
    ping -c 1 $3.$c | grep -B 1 "1 received" | grep -E -o '([0-9]{1,3}[\.]){3}([0-9]{1,3})' &
    killall ping 2>/dev/null
  done
}

# Determine IP Class and only accept Class C address.
class(){
  dots=$(grep -o '\.' <<< $1 | wc -l)
  case $dots in
    '0')
      echo 'Class A adress input. Please input a class C address.'
      exit
      ;;
    '1')
      echo 'Class B adress input. Please input a class C address.'
      exit
      ;;
    '2')
      address=$(grep -E -o '([0-9]{1,3}[\.]){2}([0-9]{1,3})' <<< $1)
      ;;
    '3')
        echo "Please enter a Class C subnet or a range"
        echo "Example ./sweep.sh 192.168.1  ||  ./sweep.sh 192.168.1.5-7"
        echo "Port scanning can be done in the same format"
        echo "Example ./sweep.sh 192.168.1 22 23  ||  ./sweep.sh 192.168.1.5-7 22 23"
      ;;
    '*')
      echo "Please enter a class C IP address to scan"
      exit
      ;;
  esac
}


# MAIN FUNCTION #
args=$(wc -w <<< $@)
case $args in
  0)
    echo ""
    echo 'Usage: ./sweep.sh <Class C IP or Class D range> [Port] [Port]...'
    echo ""
    echo 'If a port is not specified a ping sweep will be initiated'
    echo 'If a port is specified sweep will scan all ip addresses for an opening on that port'
    echo 'Multiple ports can be specified with a space delimiter (up to 8 ports)'
    echo ""
    exit
    ;;
  1)
    if [ $(grep '[\-]' <<< $1) ]; then
      subnet=$(grep -E -o '([0-9]{1,3}[\.]){2}([0-9]{1,3})' <<< $1)
      base=$(grep -E -o '[0-9]{1,5}[\-]' <<< $1 | sed 's/\-//g')
      top=$(grep -E -o '[\-][0-9]{1,5}' <<< $1 | sed 's/\-//g')
      pingsweep_range $base $top $subnet
      exit
    else
      class $1
      pingsweep $address
      exit
    fi
    ;;
  [2-9])
    if [ $(grep '[\-]' <<< $1) ]; then
      subnet=$(grep -E -o '([0-9]{1,3}[\.]){2}([0-9]{1,3})' <<< $1)
      base=$(grep -E -o '[0-9]{1,5}[\-]' <<< $1 | sed 's/\-//g')
      top=$(grep -E -o '[\-][0-9]{1,5}' <<< $1 | sed 's/\-//g')
      ports=$(sed "s/$1//g" <<< $@)
      netcat_range $base $top $subnet "$ports"
      exit
    else
      class $1
      ports=$(sed "s/$address //g" <<< $@)
      netcat $address "$ports"
      exit
    fi
    ;;
  '*')
    echo "Something went wrong. Please enter up to 8 ports."
  esac
