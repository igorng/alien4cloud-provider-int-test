#!/bin/bash

DEVICE=$1
LOCATION=$2
echo "whoami `whoami`"
echo "mounting $DEVICE to $LOCATION"
sudo mount $DEVICE $LOCATION