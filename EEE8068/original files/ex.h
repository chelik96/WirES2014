/* Dr. A Bystrov, EECE, Newcastle University, 8/12/2008  */
#define LEDS_P (int*)0x10000000

#define STATE_BUTTONS_P (int*)0x10000004
#define STATE_MASK_ST1 0x08
#define STATE_MASK_ST2 0x80
#define STATE_MASK_ST3 0x40

#define TIMER_P (int*)0x10000008
#define TIMER_COMPARE_P (int*)0x1000000C

#define INT_RAW_P (int*)0x10000018
#define INT_ENABLE_P (int*)0x1000001C
#define INT_MASK_TIMER 0x01
#define INT_MASK_BUTTON2 0x40
#define INT_MASK_BUTTON3 0x80

#define HALT_P (int*)0x10000020

#define IRQ_ENABLE \
asm (	"mrs r2, cpsr\n\t"\
	"bic r2, r2, #0x80\n\t"\
	"msr cpsr_c, r2"\
	: /* no output registers */\
	: /* no input registers */\
	: /* clobber list */ "r2");

#define IRQ_DISABLE \
asm (	"mrs r2, cpsr\n\t"\
	"orr r2, r2, #0x80\n\t"\
	"msr cpsr_c, r2"\
	: /* no output registers */\
	: /* no input registers */\
	: /* clobber list */ "r2");

#define FIQ_ENABLE \
asm (	"mrs r2, cpsr\n\t"\
	"bic r2, r2, #0x40\n\t"\
	"msr cpsr_c, r2"\
	: /* no output registers */\
	: /* no input registers */\
	: /* clobber list */ "r2");

#define FIQ_DISABLE \
asm (	"mrs r2, cpsr\n\t"\
	"orr r2, r2, #0x40\n\t"\
	"msr cpsr_c, r2"\
	: /* no output registers */\
	: /* no input registers */\
	: /* clobber list */ "r2");

#define SVC_MODE \
asm (	"msr     cpsr_c, #0xD3")

#define IRQ_MODE \
asm (	"msr     cpsr_c, #0xD2")

#define FIQ_MODE \
asm (	"msr     cpsr_c, #0xD1");

#define USR_MODE \
asm (	"msr     cpsr_c, #0x50");


#define IRQ_STACK_INIT \
asm ("ldr r13, =__irq_stack_top__");

#define FIQ_STACK_INIT \
asm ("ldr r13, =__fiq_stack_top__");

#define SVC_STACK_INIT \
asm ("ldr r13, =__svc_stack_top__");

#define USR_STACK_INIT \
asm ("ldr r13, =__usr_stack_top__");

#define SWI_STACK_INIT \
asm ("ldr r13, =__swi_stack_top__");






