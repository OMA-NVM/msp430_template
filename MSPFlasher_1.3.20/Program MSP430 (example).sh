#!/bin/bash

export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH

clear
./MSP430Flasher -w "Firmware.txt" -v -g -z [VCC]
read -p "Press any key to continue..."
./MSP430Flasher -r [FirmwareOutput.txt,MAIN]
read -p "Press any key to continue..."
