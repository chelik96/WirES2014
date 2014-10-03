/* A.Bystrov, EECE, Newcastle University, UK, 8/12/2008 */

MEMORY
{
  CODE (rx) :  ORIGIN = 0x00000000, LENGTH = 0x00010000 /* start    0, length 64k */
  DATA (rw) :  ORIGIN = 0x00010000, LENGTH = 0x0000c000 /* start  64k, length 56k */
  STACK (rw) : ORIGIN = 0x0001c000, LENGTH = 0x00004000 /* start 120k, length  8k */
}

/* Stack sizes */
SVC_STACK_SIZE = 1024; 	/* Supervisor mode -- default under KMD */
USR_STACK_SIZE = 2048; 	/* User mode */
SYS_STACK_SIZE = 256; 	/* System mode -- we don't use it */
FIQ_STACK_SIZE = 1024; 	/* FIQ mode */
IRQ_STACK_SIZE = 1024; 	/* IRQ mode */
SWI_STACK_SIZE = 256; 	/* Software interrupt mode */
ABT_STACK_SIZE = 256; 	/* Abort mode -- we don't use it */
UND_STACK_SIZE = 256; 	/* Unefined mode -- we don't use it */


ENTRY (_startup)

/* Section Definitions */

SECTIONS
{
  /* first section is .text which is used for code */
  . = 0x00000000;
  .text : { *startup.o (.text) }>CODE =0
  .text :
  {
    *(.text)                   /* remaining code */

    *(.glue_7t) *(.glue_7)

  } >CODE =0

  . = ALIGN(4);

  /* .rodata section which is used for read-only data (constants) */

  .rodata :
  {
    *(.rodata)
  } >CODE =0

  . = ALIGN(4);

  _etext = . ;
  PROVIDE (etext = .);

  /* .data section which is used for initialized data */

  .data : AT (_etext)
  {
    _data = . ;
    *(.data)
    SORT(CONSTRUCTORS)
  } >DATA =0

  . = ALIGN(4);

  _edata = . ;
   PROVIDE (edata = .);

  /* .bss section which is used for uninitialized data */
    .bss : {
        __bss_start__ = . ;
        *(.shbss)
        *(.bss .bss.* .gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN (8);
        __bss_end__ = .;
    } >DATA

  .int_data :  
   { 
   *(.internal_ram_top) 
   } >DATA =0

    .stack : {
        __stack_start__ = . ;

        . += FIQ_STACK_SIZE;
        . = ALIGN (4);
        __fiq_stack_top__ = . ;

        . += IRQ_STACK_SIZE;
        . = ALIGN (4);
        __irq_stack_top__ = . ;

        . += SWI_STACK_SIZE;
        . = ALIGN (4);
        __swi_stack_top__ = . ;

        . += SVC_STACK_SIZE;
        . = ALIGN (4);
        __svc_stack_top__ = . ;

        . += ABT_STACK_SIZE;
        . = ALIGN (4);
        __abt_stack_top__ = . ;

        . += UND_STACK_SIZE;
        . = ALIGN (4);
        __und_stack_top__ = . ;

        . += SYS_STACK_SIZE;
        . = ALIGN (4);
        __sys_stack_top__ = . ;

        . += USR_STACK_SIZE;
        . = ALIGN (4);
        __usr_stack_top__ = . ;

        __stack_end__ = .;
    } >STACK =0


    . = ALIGN(4);
    _end = . ;
    __end = . ;
    PROVIDE(end = .);

    .stab 0 (NOLOAD) : {
        *(.stab)
    }

    .stabstr 0 (NOLOAD) : {
        *(.stabstr)
    }
}

