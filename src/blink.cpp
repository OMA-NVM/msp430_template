// FreeRTOSv202406.01-LTS
#include "FreeRTOS.h"
#include "task.h"
#include "UART.h"

// void uartInitialize() {
//     P2SEL0 &= ~(BIT0 | BIT1);
//     P2SEL1 |= BIT0 | BIT1;  // USCI_A0 UART operation

//     // // Startup clock system with max DCO setting ~8MHz
//     // CSCTL0_H = CSKEY_H;                     // Unlock CS registers
//     // CSCTL1 = DCOFSEL_3 | DCORSEL;           // Set DCO to 8MHz
//     // CSCTL2 = SELA__VLOCLK | SELS__DCOCLK | SELM__DCOCLK;
//     // CSCTL3 = DIVA__1 | DIVS__1 | DIVM__1;   // Set all dividers
//     // CSCTL0_H = 0;                           // Lock CS registers

//     // Configure USCI_A0 for UART mode
//     UCA0CTLW0 = UCSWRST;         // Put eUSCI in reset
//     UCA0CTLW0 |= UCSSEL__SMCLK;  // CLK = SMCLK
//     // Baud Rate calculation
//     // 8000000/(16*9600) = 52.083
//     // Fractional portion = 0.083
//     // User's Guide Table 21-4: UCBRSx = 0x04
//     // UCBRFx = int ( (52.083-52)*16) = 1
//     UCA0BRW = 52;  // 8000000/16/9600
//     UCA0MCTLW |= UCOS16 | UCBRF_1 | 0x4900;
//     UCA0CTLW0 &= ~UCSWRST;  // Initialize eUSCI
//     UCA0IE |= UCRXIE;       // Enable USCI_A0 RX interrupt
// }
// void send(char c) {
//     // Wait for previos action to be finished
//     while (!(UCA0IFG & UCTXIFG));
//     UCA0TXBUF = c;
// }
void blink(void *);
void setupHardware(void);

void blink(void *pvParams) {
    TickType_t previousWakeTime = 0;

    // volatile unsigned int i;  // volatile to prevent optimization
    // for (int j = 0; j < 10; j++) {
    //     P5OUT ^= BIT0;  // Toggle P5.1 using exclusive-OR (LED2 green)

    //     i = 50000;  // SW Delay
    //     do i--;
    //     while (i != 0);
    // }

    for (;;) {
        // TODO somehow this does not come back
        //  volatile unsigned int i;  // volatile to prevent optimization
        //  for (int j = 0; j < 10; j++) {
        P1OUT ^= BIT0;  // Toggle P1.0 using exclusive-OR (LED1)

        //     i = 50000;  // SW Delay
        //     do i--;
        //     while (i != 0);
        // }
        // vTaskDelay(0);
        xTaskDelayUntil(&previousWakeTime, 10);
    }
}

void vApplicationIdleHook() {
}

void setupHardware(void) {
    WDTCTL = WDTPW | WDTHOLD;  // Stop WDT
    PM5CTL0 &= ~LOCKLPM5;      // Disable the GPIO power-on default high-impedance mode
                               // to activate previously configured port settings

    P1DIR |= BIT0;   // set P1.0 as output
    P1OUT &= ~BIT0;  // clear P1.0

    P4DIR |= BIT7;   // set P4.7 as output
    P4OUT &= ~BIT7;  // clear P4.7

    P5DIR |= BIT1;   // set P5.1 as output
    P5OUT &= ~BIT1;  // clear P5.1

    P5DIR |= BIT0;   // set P5.0 as output
    P5OUT &= ~BIT0;  // clear P5.0

    uartInitialize();

//   initGPIO();
//   initClockTo16MHz();
//   initUART();

// #if UART_MODE == SMCLK_9600
//     __bis_SR_register(LPM3_bits + GIE);       // Since ACLK is source, enter LPM3, interrupts enabled
// #else
//     __bis_SR_register(LPM0_bits + GIE);       // Since SMCLK is source, enter LPM0, interrupts enabled
// #endif
//   __no_operation();                         // For debugger


}

int main(void) {
    setupHardware();

        while(true){
    send('A');
    send('\n');
        // __delay_cycles(3);
    }

    BaseType_t a = xTaskCreate(blink, "blink", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 1, NULL);

    if (a == errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY)  // error case
    {
        volatile unsigned int i;  // volatile to prevent optimization
        for (int j = 0; j < 10; j++) {
            P5OUT ^= BIT1;  // Toggle P5.1 using exclusive-OR (LED2 red)

            i = 50000;  // SW Delay
            do i--;
            while (i != 0);
        }
    } else {                      // no error creating
        volatile unsigned int i;  // volatile to prevent optimization
        for (int j = 0; j < 10; j++) {
            P4OUT ^= BIT7;  // Toggle P4.7 using exclusive-OR (LED2 blue)

            i = 50000;  // SW Delay
            do i--;
            while (i != 0);
        }
    }

    vTaskStartScheduler();

    __no_operation();  // this should never be reached
    for (;;);
}
