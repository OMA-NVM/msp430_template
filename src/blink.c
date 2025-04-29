#include "FreeRTOS.h"
#include "task.h"

void blink(void *pvParams) {
    TickType_t previousWakeTime = 0;
    // P1OUT ^= BIT0;  // blink LED
    for (;;) {
        P1OUT ^= BIT0;  // blink LED
        vTaskDelay(1);
        // xTaskDelayUntil(&previousWakeTime, 1);
    }
}
void vApplicationIdleHook(){
        // volatile unsigned int i;            // volatile to prevent optimization

        // P1OUT ^= 0x01;                      // Toggle P1.0 using exclusive-OR

        // i = 50000;                          // SW Delay
        // do i--;
        // while(i != 0);
}

int main(void) {
    // xTaskCreate(blink, "blink", 1024, NULL, tskIDLE_PRIORITY+1, NULL);

    vTaskStartScheduler();

    __no_operation();  // this should never be reached
    for (;;);
}
