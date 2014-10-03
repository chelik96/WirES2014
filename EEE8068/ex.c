#include "ex.h"

// number of LED lights to control
#define NUM_OF_TASKS  8
// least common mulitple of flash durations (ms) 
#define FULL_PERIOD   408408000
// define the period in ms of one cycle of PWM for leds
#define PWM_CYCLE 20

// Driver State Global Variable
int leds        = 0; // stores the state of the 8 leds (on/off)
// Scheduling State Global Variable
int tasknum     = 0; // stores the current led task to calculate

// Global Variables Used for phase correction
int int_clock   = 0; // used to recover phase of leds by keeping a clock in ms
int overrun_detected = 0;

// Global Variables Used for overrun testing
int overrunning = 0; // if in 'overrun mode' add intentional delay for testing
int had_overrun = 0; // if overrun mode stopped rephase the leds to int-clock
int do_overrun  = 0; // if button pressed 'overrun mode' should toggle
int overrun_led = 4; // keep track of which led task should cause overrun

// Contains the instructions and variables passed to task function
struct task_inst {
	// Task Parameters
	int phase,
		n,
		pwm_inc,
		flash_inc,
		flash_dur;
	// Task State Variables
	int pwm_cnt, 
		flash_cnt,
		updown;
};

// Contains the list of tasks, one for each LED on the board
// Each requires different timing, such that a single PWM is 20ms
// (e.g. for first task 200ms/10 = 20ms, or for last 340ms/17 = 20ms)
// and it takes the correct amount of time to complete a cycle
// (e.g. for first task 200ms/8 = 25 cycles of 20ms = 500ms one way, 1s total) 
struct task_inst task_list[NUM_OF_TASKS] = {
	{3, 2, 10, 8, 200, 0, 0, 0},
	{3, 1, 11, 8, 220, 0, 0, 0},
	{3, 0, 12, 8, 240, 0, 0, 0},
	{3, 3, 13, 8, 260, 0, 0, 0},
	{1, 6, 14, 8, 280, 0, 0, 0},
	{1, 5, 15, 8, 300, 0, 0, 0},
	{2, 4, 16, 8, 320, 0, 0, 0},
	{2, 7, 17, 8, 340, 0, 0, 0}
};

void correct_phase(struct task_inst *d)
{
	// Use current full duration timer to computer
	// state of a task and refersh it's state variables
	int flash_dur_ms = d->pwm_inc * 100;
	int phase_ms = int_clock % flash_dur_ms;
	
	// Calculate if we should be brightening or dimming
	d->updown  = (phase_ms < (flash_dur_ms<<2)) ? 1 : 0;
	
	// Calculate How many 20ms pwm have we should have completed so far
	if (d->updown == 0) phase_ms = phase_ms<<1;
	d->pwm_cnt   = (phase_ms / PWM_CYCLE) * d->pwm_inc;
	
	// Calculate how remainder of the 20ms pwm is left
	d->flash_cnt = phase_ms % PWM_CYCLE;
}

// Determines correct state of one LED based on given instructions
void __attribute__ ((naked)) task(struct task_inst *d)
{
	// Increment pulse width modulation count by the period
	d->pwm_cnt = d->pwm_cnt + d->pwm_inc;
	// Count up to the half period before reseting and starting again
	if (d->pwm_cnt >= d->flash_dur) {
		d->pwm_cnt = 0;
		// If we hit the boundaries of PWM cycle need to switch direction
		// nb. '1' means upwards, '0' means downwards in 'updown' variable
		if (d->flash_cnt >= d->flash_dur) d->updown = 0;
		if (d->flash_cnt <= 0)            d->updown = 1;
		// Change to new brightness level
		if (d->updown == 1) {
			d->flash_cnt = d->flash_cnt + d->flash_inc;
		} else {
			d->flash_cnt = d->flash_cnt - d->flash_inc;
		}
	}
	// Update leds with new settings
	leds &= ~(1 << d->n);
	leds ^= d->pwm_cnt < d->flash_cnt ? 1<<d->n : 0;
	// Finished Task, so Perform SWI
	// nb. If task overruns IRQ will happen instead
	asm("swi 0");
}

// Entered when no tasks left to perform, waits for next interupt
void __attribute__ ((naked)) sleep()
{
	// Assembly to prevent compiler eliminating loops
	asm("sleepmode: b sleepmode"); 
}

// Ensures all tasks are run - only 6 per interupt
void __attribute__ ((naked)) dispatch()
{
	int time_odd, phase_odd, phase_even;
	if (tasknum < NUM_OF_TASKS) {
		// Testing by intentially causing delay to a set task 
		// when the button is pressed
		if (tasknum == overrun_led) {
			// remember current overload State so button will only toggle it.
			overrunning |= do_overrun;
			if (overrunning) {
				do_overrun = 0;
				// Delay the system for a while
				int timer_end = 0xFFFF;
				int i=0;
				for (i=0;i<timer_end;i++) {
					asm("nop"); // Don't do anything.. just delay
				}
			}
		}		
		// Increment the current task to point to the next one (can't do after)
		tasknum++;
		// Jump past phased tasks not in current phase
		// i.e ignore even tasks when timer compare is odd and visa-versa
		time_odd   = (*TIMER_COMPARE_P & 1 == 1);
		phase_odd  = (task_list[tasknum-1].phase & 0x01 == 1);
		phase_even = (task_list[tasknum-1].phase & 0x02 == 2);
		if ((phase_odd && time_odd) | (phase_even && !time_odd)) {
			// Goto User Mode & Run the Task
			USR_MODE;
			task(&task_list[tasknum-1]);
		}
	} else {
		// can't be overruning because we made it to the end
		// so now need to rephase back
		if (overrunning == 1) {
			do_overrun = 0;
			overrunning = 0;
			had_overrun = 1;
		}
		sleep(); // Tasks done - Wait for next irq
	}
}

// Function Entered On Every Timer interupt, restarts processing of tasks list
void __attribute__ ((naked)) irq()
{
	// update internal phase reset clock
	int_clock++;
	// all tasks sync up again after about 4 3/4 days - use for clock modulus
	if (int_clock > FULL_PERIOD) int_clock = 0;
	asm("beforeoverruntest:");
	// If overrun detected in last dispatch, correct phases before continuing
	if ((had_overrun == 1) && (*TIMER_COMPARE_P == 0)) {
		int i;
		// Interupts have to be enabled throughout - takes a while
		IRQ_DISABLE;
		FIQ_DISABLE;
		for (i = 0; i < NUM_OF_TASKS; i++) {
			correct_phase(&task_list[i-1]);
		}
		// Corrected from overrun now - back to normal running
		had_overrun = 0;
		IRQ_ENABLE;
		FIQ_ENABLE;
	}

	// Reset IRQ request
	*INT_RAW_P &= ~INT_MASK_TIMER;
	// Setup next interupt
	*TIMER_COMPARE_P = *TIMER_P + 1;
	
	// Reset task queue
	tasknum = 0;
	// Reset overrun detector boolean
	//overrun_detected = 1;
	
	// Call Dispatcher, start processing the tasks for this millisecond
	dispatch();
}

// Used as a way to toggle overrun testing
void __attribute__ ((naked)) fiq()
{
	// Reset the request
	*INT_ENABLE_P |= INT_MASK_FIQBUT;
	
	// Toggle the overload state
	// (but only once until overload applied in dispatch)
	do_overrun = !do_overrun;

	// Reset LEDs using the main function
	SVC_MODE;
	main();
}

// Called at task end (user mode), sets supervisor mode and updates hardware
void __attribute__ ((naked)) swi()
{
	// Interupts get disabled on operating mode change, prevent this
	IRQ_ENABLE;
	FIQ_ENABLE;
	// HW Driver: Set the Physical LEDs based on user mode modified variable
	*LEDS_P = leds;
	// Call Dispatch to look for a new task
	dispatch();
}

// Starts the system, reset initial variable etc.
int main ()
{
	// Initialize state - Reset task variables
	//int i;
	//for (i=0;i<NUM_OF_TASKS;i++) {
	//	task_list[i].flash_cnt = 0;
	//	task_list[i].pwm_cnt   = 0;
	//	task_list[i].updown    = 0;
	//}
	// Initialize Leds
	leds    = 0;
	*LEDS_P = leds;
	// Initialise timer
	*TIMER_COMPARE_P = *TIMER_P + 1;
	// IRQ input unmask
	*INT_ENABLE_P |= INT_MASK_TIMER;
	// Interupts have to be enabled throughout
	IRQ_ENABLE;
	FIQ_ENABLE;
	// Reset IRQ request
	*INT_RAW_P &= ~INT_MASK_TIMER;
	// Just sleep until timer raises first interrupt
	sleep();
}