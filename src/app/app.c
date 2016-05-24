#include "LPC11xx.h"

#define BIT(n) (1UL << (n))

static volatile uint32_t flag = 0;

void SysTick_Handler()
{
    static uint32_t counter = 0;

    counter++;

    if (counter >= 1000) {
        counter = 0;
        flag = 1;
    }
}

int main()
{    
    LPC_SYSCON->SYSAHBCLKCTRL |= BIT(6);    // enable gpio clk
    LPC_IOCON->JTAG_nTRST_PIO1_2 |= 0x01;
    LPC_GPIO1->DIR |= BIT(2);
    LPC_GPIO1->DATA = 0;

    SysTick_Config(SystemFrequency / 1000);

    for (;;) {
        if (flag) {
            flag = 0;
            LPC_GPIO1->DATA ^= BIT(2);
        }
    }
}
