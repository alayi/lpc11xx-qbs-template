#!/bin/sh

lpc21isp -hex -wipe -verify `find . -name *.hex` /dev/ttyUSB0 115200 12000

