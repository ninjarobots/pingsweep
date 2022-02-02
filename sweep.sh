#!/usr/bin/env bash

# Ping sweep Module
pingsweep(){
  for sub_address in {1..254}; do
    ping -c 1 $1.$sub_address | grep -B 1 "1 received" | grep -E -o '([0-9]{1,3}[\.]){3}([0-9]{1,3})' &
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
    '2' | '3')
      address=$(grep -E -o '([0-9]{1,3}[\.]){2}([0-9]{1,3})' <<< $1)
      ;;
    '*')
      echo "Please enter a class C IP address to scan"
      exit
      ;;
  esac
}


# MAIN FUNCTION #
class $1
pingsweep $address
