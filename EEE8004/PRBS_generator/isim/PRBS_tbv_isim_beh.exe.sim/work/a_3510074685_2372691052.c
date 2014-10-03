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
static const char *ng0 = "//TOWER5/home29/b3062393/Projects/EEE8004/PRBS_generator/PRBS_tbv.vhd";



static void work_a_3510074685_2372691052_p_0(char *t0)
{
    char *t1;
    char *t2;
    int64 t3;
    char *t4;
    int t5;
    char *t6;
    int t7;
    int t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    int64 t14;

LAB0:    t1 = (t0 + 1480U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(34, ng0);
    t3 = (100 * 1000LL);
    t2 = (t0 + 1380);
    xsi_process_wait(t2, t3);

LAB6:    *((char **)t1) = &&LAB7;

LAB1:    return;
LAB4:    xsi_set_current_line(35, ng0);
    t2 = (t0 + 924U);
    t4 = *((char **)t2);
    t5 = *((int *)t4);
    t2 = (t0 + 3236);
    *((int *)t2) = 0;
    t6 = (t0 + 3240);
    *((int *)t6) = t5;
    t7 = 0;
    t8 = t5;

LAB8:    if (t7 <= t8)
        goto LAB9;

LAB11:    xsi_set_current_line(41, ng0);

LAB23:    *((char **)t1) = &&LAB24;
    goto LAB1;

LAB5:    goto LAB4;

LAB7:    goto LAB5;

LAB9:    xsi_set_current_line(36, ng0);
    t9 = (t0 + 1712);
    t10 = (t9 + 32U);
    t11 = *((char **)t10);
    t12 = (t11 + 40U);
    t13 = *((char **)t12);
    *((unsigned char *)t13) = (unsigned char)2;
    xsi_driver_first_trans_fast(t9);
    xsi_set_current_line(37, ng0);
    t2 = (t0 + 856U);
    t4 = *((char **)t2);
    t3 = *((int64 *)t4);
    t14 = (t3 / 2);
    t2 = (t0 + 1380);
    xsi_process_wait(t2, t14);

LAB14:    *((char **)t1) = &&LAB15;
    goto LAB1;

LAB10:    t2 = (t0 + 3236);
    t7 = *((int *)t2);
    t4 = (t0 + 3240);
    t8 = *((int *)t4);
    if (t7 == t8)
        goto LAB11;

LAB20:    t5 = (t7 + 1);
    t7 = t5;
    t6 = (t0 + 3236);
    *((int *)t6) = t7;
    goto LAB8;

LAB12:    xsi_set_current_line(38, ng0);
    t2 = (t0 + 1712);
    t4 = (t2 + 32U);
    t6 = *((char **)t4);
    t9 = (t6 + 40U);
    t10 = *((char **)t9);
    *((unsigned char *)t10) = (unsigned char)3;
    xsi_driver_first_trans_fast(t2);
    xsi_set_current_line(39, ng0);
    t2 = (t0 + 856U);
    t4 = *((char **)t2);
    t3 = *((int64 *)t4);
    t14 = (t3 / 2);
    t2 = (t0 + 1380);
    xsi_process_wait(t2, t14);

LAB18:    *((char **)t1) = &&LAB19;
    goto LAB1;

LAB13:    goto LAB12;

LAB15:    goto LAB13;

LAB16:    goto LAB10;

LAB17:    goto LAB16;

LAB19:    goto LAB17;

LAB21:    goto LAB2;

LAB22:    goto LAB21;

LAB24:    goto LAB22;

}


extern void work_a_3510074685_2372691052_init()
{
	static char *pe[] = {(void *)work_a_3510074685_2372691052_p_0};
	xsi_register_didat("work_a_3510074685_2372691052", "isim/PRBS_tbv_isim_beh.exe.sim/work/a_3510074685_2372691052.didat");
	xsi_register_executes(pe);
}
