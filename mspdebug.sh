#!/bin/bash
export LD_LIBRARY_PATH=./msp430-gcc/bin
mspdebug "$@"
