#include "ex.h"

/* inline function example */
void __attribute__ ((always_inline)) task ()
{
}


/* example of IRQ */
void __attribute__ ((naked)) irq ()
{
  /* once called -- IRQ becomes disabled up util return */
  *INT_RAW_P &= ~INT_MASK_TIMER; /* reset IRQ request */
  IRQ_ENABLE; /* use only if you need nested interrupts */
}

/* note that swi() is missing here - add it! */



/* example of main */
int main ()
{
  *LEDS_P = 0xFF;  /* light the leds */
  *TIMER_COMPARE_P = *TIMER_P + 128;
  IRQ_ENABLE; /* IRQ enable, this is different from unmasking*/
  *INT_ENABLE_P |= INT_MASK_TIMER; /* IRQ input unmask */

  while (1); /* sleep until interrupt */
}