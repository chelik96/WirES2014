/* Dr. A Bystrov, EECE, Newcastle University, 8/12/2008  */

	.file	"startup.s"
        .code 32

/* Vector table */
        .global _startup
        .type	_startup, %function
_startup:
	B	init			/* 0x00 Reset handler */
        .type	undefvec, %function
undefvec:
	B	undefvec		/* 0x04 Undefined Instruction */
        .type	swivec, %function
swivec:
	B	swi			/* 0x08 Software Interrupt, swi() must(!) be defined in C-code  */
        .type	pabtvec, %function
pabtvec:
	B	pabtvec			/* 0x0C Prefetch Abort */
        .type	dabtvec, %function
dabtvec:
	B	dabtvec 		/* 0x10 Data Abort */
        .type	rsvdvec, %function
rsvdvec:
	B	rsvdvec 		/* 0x14 reserved  */
        .type	irqvec, %function
irqvec:
	B	irq			/* 0x18 IRQ, irq() must(!) be defined in C-code */
        .type	fiqvec, %function
fiqvec:
	B	fiq			/* 0x1C FIQ, fiq() must(!) be defined in C-code */

/* controller initialisation */
init:	
        mov     R0, #0xd1 		/* FIQ mode */
        msr     cpsr_c, R0

	mov	r1, #_fiq_stack_top_
        ldr     R13, [r1]		/* init FIQ stack */

        mov     R0, #0xd2 		/* IRQ mode*/
        msr     cpsr_c, R0

	mov	r1, #_irq_stack_top_
        ldr     R13, [r1]		/* init IRQ stack */

        mov     R0, #0xd3 		/* Supervisor mode */
        msr     cpsr_c, R0

	mov	r1, #_svc_stack_top_
	ldr	r13, [r1]		/* init Supervisor stack */

	b	main 			/* goto main() */
_usr_stack_top_:	.word __usr_stack_top__
_fiq_stack_top_:	.word __fiq_stack_top__
_irq_stack_top_:	.word __irq_stack_top__
_svc_stack_top_:	.word __svc_stack_top__
_abt_stack_top_:	.word __abt_stack_top__
_und_stack_top_:	.word __und_stack_top__
_sys_stack_top_:	.word __sys_stack_top__
_swi_stack_top_:	.word __swi_stack_top__
	.size	_startup, .-_startup

/* These are examples of .s functions visible from C */
	.global	fiq_enable
	.type fiq_enable, %function
fiq_enable:
	push	{r2}
	mrs     R2, cpsr
        bic     R2, R2, #0x40
        msr     cpsr_c, R2	
	pop	{r2}
	mov	pc, lr
	.size	fiq_enable, .-fiq_enable

	.global	fiq_disable
	.type	fiq_disable, %function
fiq_disable:
	push	{r2}
	mrs     R2, cpsr
        orr     R2, R2, #0x40
        msr     cpsr_c, R2	
	pop	{r2}
	mov	pc, lr
	.size	fiq_disable, .-fiq_disable

	.global	irq_enable
	.type	irq_enable, %function
irq_enable:
	push	{r2}
	mrs     R2, cpsr
        bic     R2, R2, #0x80
        msr     cpsr_c, R2
	pop	{r2}
	mov	pc, lr
	.size	irq_enable, .-irq_enable

	.global	irq_disable
	.type	irq_disable, %function
irq_disable:
	push	{r2}
	mrs     R2, cpsr
        orr     R2, R2, #0x80
        msr     cpsr_c, R2
	pop	{r2}
	mov	pc, lr
	.size	irq_disable, .-irq_disable

        .end

