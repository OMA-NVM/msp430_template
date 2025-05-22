#!/usr/bin/env python3

import serial

DEVICE = '/dev/tty.usbmodem113203'
ser = serial.Serial(DEVICE, timeout = 600)
# ser = serial.Serial()
# ser.port = DEVICE
# ser.baudrate = 115200
# ser.timeout = 600
# ser.rts = False
# ser.dtr = False

# ser.open()

while True:
    x = ser.readline()
    result = x.decode()
    print(result)
