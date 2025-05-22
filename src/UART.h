#include <msp430.h>
// #include <msp430fr5994.h>
void initGPIO();
void initClockTo16MHz();
void initUART();
void uartInitialize();
// void send(int number);
// void send(unsigned int number);
// void send(long number);
// void send(unsigned long number);
void send(char c);
// void send(const char *c);

// void sendln(int number);
// void sendln(unsigned int number);
// void sendln(long number);
// void sendln(unsigned long number);
// void sendln(char c);
// void sendln(const char *c);
