#!/bin/bash

export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH

clear
# -n switch is mandatory for MSP432!
./MSP430Flasher -n "MSP432P401R" -w "Firmware432.txt" -v -g -z [VCC]
read -p "Press any key to continue..."
./MSP430Flasher -n "MSP432P401R" -r [FirmwareOutput432.txt,MAIN]
read -p "Press any key to continue..."
