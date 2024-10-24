#!/bin/bash
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
MSP430Flasher "$@"
