/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x8ef4fb42 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "//TOWER5/home29/b3062393/Projects/EEE8004/BIST/PBRS_generator.vhd";
extern char *IEEE_P_2592010699;

unsigned char ieee_p_2592010699_sub_2507238156_503743352(char *, unsigned char , unsigned char );


static void work_a_2356699146_3212880686_p_0(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned char t11;
    int t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned char t16;
    unsigned char t17;
    char *t18;
    char *t19;
    char *t20;

LAB0:    xsi_set_current_line(21, ng0);
    t1 = (t0 + 776U);
    t2 = *((char **)t1);
    t1 = (t0 + 1744);
    t3 = (t1 + 32U);
    t4 = *((char **)t3);
    t5 = (t4 + 40U);
    t6 = *((char **)t5);
    memcpy(t6, t2, 10U);
    xsi_driver_first_trans_fast_port(t1);
    xsi_set_current_line(23, ng0);
    t1 = (t0 + 776U);
    t2 = *((char **)t1);
    t7 = (3 - 9);
    t8 = (t7 * -1);
    t9 = (1U * t8);
    t10 = (0 + t9);
    t1 = (t2 + t10);
    t11 = *((unsigned char *)t1);
    t3 = (t0 + 776U);
    t4 = *((char **)t3);
    t12 = (0 - 9);
    t13 = (t12 * -1);
    t14 = (1U * t13);
    t15 = (0 + t14);
    t3 = (t4 + t15);
    t16 = *((unsigned char *)t3);
    t17 = ieee_p_2592010699_sub_2507238156_503743352(IEEE_P_2592010699, t11, t16);
    t5 = (t0 + 1780);
    t6 = (t5 + 32U);
    t18 = *((char **)t6);
    t19 = (t18 + 40U);
    t20 = *((char **)t19);
    *((unsigned char *)t20) = t17;
    xsi_driver_first_trans_delta(t5, 0U, 1, 0LL);
    xsi_set_current_line(24, ng0);
    t1 = (t0 + 776U);
    t2 = *((char **)t1);
    t8 = (9 - 9);
    t9 = (t8 * 1U);
    t10 = (0 + t9);
    t1 = (t2 + t10);
    t3 = (t0 + 1780);
    t4 = (t3 + 32U);
    t5 = *((char **)t4);
    t6 = (t5 + 40U);
    t18 = *((char **)t6);
    memcpy(t18, t1, 9U);
    xsi_driver_first_trans_delta(t3, 1U, 9U, 0LL);
    t1 = (t0 + 1700);
    *((int *)t1) = 1;

LAB1:    return;
}


extern void work_a_2356699146_3212880686_init()
{
	static char *pe[] = {(void *)work_a_2356699146_3212880686_p_0};
	xsi_register_didat("work_a_2356699146_3212880686", "isim/BIST_isim_beh.exe.sim/work/a_2356699146_3212880686.didat");
	xsi_register_executes(pe);
}
