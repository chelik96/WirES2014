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
static const char *ng0 = "//TOWER5/home29/b3062393/Projects/EEE8004/ALU/ALU_tbv.vhd";
extern char *IEEE_P_0774719531;

char *ieee_p_0774719531_sub_436279890_2162500114(char *, char *, char *, char *, int );


static void work_a_2287590165_2372691052_p_0(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    int64 t7;
    int64 t8;

LAB0:    t1 = (t0 + 1756U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(38, ng0);
    t2 = (t0 + 2132);
    t3 = (t2 + 32U);
    t4 = *((char **)t3);
    t5 = (t4 + 40U);
    t6 = *((char **)t5);
    *((unsigned char *)t6) = (unsigned char)2;
    xsi_driver_first_trans_fast(t2);
    xsi_set_current_line(39, ng0);
    t2 = (t0 + 1132U);
    t3 = *((char **)t2);
    t7 = *((int64 *)t3);
    t8 = (t7 / 2);
    t2 = (t0 + 1656);
    xsi_process_wait(t2, t8);

LAB6:    *((char **)t1) = &&LAB7;

LAB1:    return;
LAB4:    xsi_set_current_line(40, ng0);
    t2 = (t0 + 2132);
    t3 = (t2 + 32U);
    t4 = *((char **)t3);
    t5 = (t4 + 40U);
    t6 = *((char **)t5);
    *((unsigned char *)t6) = (unsigned char)3;
    xsi_driver_first_trans_fast(t2);
    xsi_set_current_line(41, ng0);
    t2 = (t0 + 1132U);
    t3 = *((char **)t2);
    t7 = *((int64 *)t3);
    t8 = (t7 / 2);
    t2 = (t0 + 1656);
    xsi_process_wait(t2, t8);

LAB10:    *((char **)t1) = &&LAB11;
    goto LAB1;

LAB5:    goto LAB4;

LAB7:    goto LAB5;

LAB8:    goto LAB2;

LAB9:    goto LAB8;

LAB11:    goto LAB9;

}

static void work_a_2287590165_2372691052_p_1(char *t0)
{
    char t17[16];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    int64 t9;
    int t10;
    int t11;
    int t12;
    char *t13;
    char *t14;
    char *t15;
    int64 t16;
    unsigned int t18;
    unsigned int t19;
    unsigned char t20;
    unsigned char t21;

LAB0:    t1 = (t0 + 1900U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(50, ng0);
    t2 = (t0 + 4064);
    t4 = (t0 + 2168);
    t5 = (t4 + 32U);
    t6 = *((char **)t5);
    t7 = (t6 + 40U);
    t8 = *((char **)t7);
    memcpy(t8, t2, 4U);
    xsi_driver_first_trans_fast(t4);
    xsi_set_current_line(51, ng0);
    t2 = (t0 + 4068);
    t4 = (t0 + 2204);
    t5 = (t4 + 32U);
    t6 = *((char **)t5);
    t7 = (t6 + 40U);
    t8 = *((char **)t7);
    memcpy(t8, t2, 4U);
    xsi_driver_first_trans_fast(t4);
    xsi_set_current_line(52, ng0);
    t2 = (t0 + 4072);
    t4 = (t0 + 2240);
    t5 = (t4 + 32U);
    t6 = *((char **)t5);
    t7 = (t6 + 40U);
    t8 = *((char **)t7);
    memcpy(t8, t2, 2U);
    xsi_driver_first_trans_fast(t4);
    xsi_set_current_line(53, ng0);
    t9 = (100 * 1000LL);
    t2 = (t0 + 1800);
    xsi_process_wait(t2, t9);

LAB6:    *((char **)t1) = &&LAB7;

LAB1:    return;
LAB4:    xsi_set_current_line(54, ng0);
    t2 = (t0 + 1200U);
    t3 = *((char **)t2);
    t10 = *((int *)t3);
    t2 = (t0 + 4074);
    *((int *)t2) = 0;
    t4 = (t0 + 4078);
    *((int *)t4) = t10;
    t11 = 0;
    t12 = t10;

LAB8:    if (t11 <= t12)
        goto LAB9;

LAB11:    xsi_set_current_line(68, ng0);

LAB38:    *((char **)t1) = &&LAB39;
    goto LAB1;

LAB5:    goto LAB4;

LAB7:    goto LAB5;

LAB9:    xsi_set_current_line(55, ng0);
    t5 = (t0 + 4082);
    t7 = (t0 + 2240);
    t8 = (t7 + 32U);
    t13 = *((char **)t8);
    t14 = (t13 + 40U);
    t15 = *((char **)t14);
    memcpy(t15, t5, 2U);
    xsi_driver_first_trans_fast(t7);
    xsi_set_current_line(56, ng0);
    t2 = (t0 + 1132U);
    t3 = *((char **)t2);
    t9 = *((int64 *)t3);
    t16 = (t9 * 2);
    t2 = (t0 + 1800);
    xsi_process_wait(t2, t16);

LAB14:    *((char **)t1) = &&LAB15;
    goto LAB1;

LAB10:    t2 = (t0 + 4074);
    t11 = *((int *)t2);
    t3 = (t0 + 4078);
    t12 = *((int *)t3);
    if (t11 == t12)
        goto LAB11;

LAB35:    t10 = (t11 + 1);
    t11 = t10;
    t4 = (t0 + 4074);
    *((int *)t4) = t11;
    goto LAB8;

LAB12:    xsi_set_current_line(57, ng0);
    t2 = (t0 + 4084);
    t4 = (t0 + 2240);
    t5 = (t4 + 32U);
    t6 = *((char **)t5);
    t7 = (t6 + 40U);
    t8 = *((char **)t7);
    memcpy(t8, t2, 2U);
    xsi_driver_first_trans_fast(t4);
    xsi_set_current_line(58, ng0);
    t2 = (t0 + 1132U);
    t3 = *((char **)t2);
    t9 = *((int64 *)t3);
    t16 = (t9 * 2);
    t2 = (t0 + 1800);
    xsi_process_wait(t2, t16);

LAB18:    *((char **)t1) = &&LAB19;
    goto LAB1;

LAB13:    goto LAB12;

LAB15:    goto LAB13;

LAB16:    xsi_set_current_line(59, ng0);
    t2 = (t0 + 4086);
    t4 = (t0 + 2240);
    t5 = (t4 + 32U);
    t6 = *((char **)t5);
    t7 = (t6 + 40U);
    t8 = *((char **)t7);
    memcpy(t8, t2, 2U);
    xsi_driver_first_trans_fast(t4);
    xsi_set_current_line(60, ng0);
    t2 = (t0 + 1132U);
    t3 = *((char **)t2);
    t9 = *((int64 *)t3);
    t16 = (t9 * 2);
    t2 = (t0 + 1800);
    xsi_process_wait(t2, t16);

LAB22:    *((char **)t1) = &&LAB23;
    goto LAB1;

LAB17:    goto LAB16;

LAB19:    goto LAB17;

LAB20:    xsi_set_current_line(61, ng0);
    t2 = (t0 + 4088);
    t4 = (t0 + 2240);
    t5 = (t4 + 32U);
    t6 = *((char **)t5);
    t7 = (t6 + 40U);
    t8 = *((char **)t7);
    memcpy(t8, t2, 2U);
    xsi_driver_first_trans_fast(t4);
    xsi_set_current_line(62, ng0);
    t2 = (t0 + 1132U);
    t3 = *((char **)t2);
    t9 = *((int64 *)t3);
    t16 = (t9 * 2);
    t2 = (t0 + 1800);
    xsi_process_wait(t2, t16);

LAB26:    *((char **)t1) = &&LAB27;
    goto LAB1;

LAB21:    goto LAB20;

LAB23:    goto LAB21;

LAB24:    xsi_set_current_line(63, ng0);
    t2 = (t0 + 776U);
    t3 = *((char **)t2);
    t2 = (t0 + 3980U);
    t4 = ieee_p_0774719531_sub_436279890_2162500114(IEEE_P_0774719531, t17, t3, t2, 1);
    t5 = (t17 + 12U);
    t18 = *((unsigned int *)t5);
    t19 = (1U * t18);
    t20 = (4U != t19);
    if (t20 == 1)
        goto LAB28;

LAB29:    t6 = (t0 + 2168);
    t7 = (t6 + 32U);
    t8 = *((char **)t7);
    t13 = (t8 + 40U);
    t14 = *((char **)t13);
    memcpy(t14, t4, 4U);
    xsi_driver_first_trans_fast(t6);
    xsi_set_current_line(64, ng0);
    t2 = (t0 + 4074);
    t10 = xsi_vhdl_mod(*((int *)t2), 4);
    t20 = (t10 == 0);
    if (t20 != 0)
        goto LAB30;

LAB32:
LAB31:    goto LAB10;

LAB25:    goto LAB24;

LAB27:    goto LAB25;

LAB28:    xsi_size_not_matching(4U, t19, 0);
    goto LAB29;

LAB30:    xsi_set_current_line(65, ng0);
    t3 = (t0 + 868U);
    t4 = *((char **)t3);
    t3 = (t0 + 3996U);
    t5 = ieee_p_0774719531_sub_436279890_2162500114(IEEE_P_0774719531, t17, t4, t3, 1);
    t6 = (t17 + 12U);
    t18 = *((unsigned int *)t6);
    t19 = (1U * t18);
    t21 = (4U != t19);
    if (t21 == 1)
        goto LAB33;

LAB34:    t7 = (t0 + 2204);
    t8 = (t7 + 32U);
    t13 = *((char **)t8);
    t14 = (t13 + 40U);
    t15 = *((char **)t14);
    memcpy(t15, t5, 4U);
    xsi_driver_first_trans_fast(t7);
    goto LAB31;

LAB33:    xsi_size_not_matching(4U, t19, 0);
    goto LAB34;

LAB36:    goto LAB2;

LAB37:    goto LAB36;

LAB39:    goto LAB37;

}


extern void work_a_2287590165_2372691052_init()
{
	static char *pe[] = {(void *)work_a_2287590165_2372691052_p_0,(void *)work_a_2287590165_2372691052_p_1};
	xsi_register_didat("work_a_2287590165_2372691052", "isim/ALU_tbv_isim_beh.exe.sim/work/a_2287590165_2372691052.didat");
	xsi_register_executes(pe);
}
