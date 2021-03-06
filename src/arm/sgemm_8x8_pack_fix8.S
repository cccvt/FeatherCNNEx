#include "fix.h"

    .equ      VERSION_MAJOR,    1
    .equ      VERSION_MINOR,    0
    .equ      VERSION_REVISION, 0

    .equ      PHASE,            1
    .equ      COPYRIGHT_YEAR,   2018

COPYRIGHT_HOLDER:
    .asciz    "tianylijun@163.com"
    .equ      NE_OK,        0
    .equ      NE_ERR,      -1

#ifdef __aarch64__
/* RSV X19~X28 */
/**************in param**************/
#define L 		 w0
#define A		 x1
#define B                x2
#define C                x3
#define LDC              w4
#define LDCX             x4
#define INT8SCALE_ADDR   x5
#define INT8SCALE        W5
#define CBK              X6

/* RSV V8~V15 */
#define VSRC_4S_A0     V0.4S
#define VSRC_4H_A0     V0.4H
#define VSRC_4H_A0_0   V0.H[0]
#define VSRC_4H_A0_1   V0.H[1]
#define VSRC_4H_A0_2   V0.H[2]
#define VSRC_4H_A0_3   V0.H[3]

#define VSRC_4S_A1     V1.4S
#define VSRC_4H_A1     V1.4H
#define VSRC_4H_A1_0   V1.H[0]
#define VSRC_4H_A1_1   V1.H[1]
#define VSRC_4H_A1_2   V1.H[2]
#define VSRC_4H_A1_3   V1.H[3]

#define VSRC_4H_B0     V2.4H
#define VSRC_4H_B1     V3.4H

#define VSRC_4S_C0     V4.4S
#define VSRC_4S_C8     V5.4S

#define VSRC_4S_C1     V6.4S
#define VSRC_4S_C9     V7.4S

#define VSRC_4S_C2     V16.4S
#define VSRC_4S_CA     V17.4S

#define VSRC_4S_C3     V18.4S
#define VSRC_4S_CB     V19.4S

#define VSRC_4S_C4     V20.4S
#define VSRC_4S_CC     V21.4S

#define VSRC_4S_C5     V22.4S
#define VSRC_4S_CD     V23.4S

#define VSRC_4S_C6     V24.4S
#define VSRC_4S_CE     V25.4S

#define VSRC_4S_C7     V26.4S
#define VSRC_4S_CF     V27.4S

#define VSRC_8B_A      V28.8B
#define VSRC_8H_A      V28.8H
#define VSRC_4H_A      V28.4H

#define VSRC_4S_SCALE  V29.4S

/* void sgemm_8x8_pack_fix8( int L, char *a, short *b, float *c, int ldc, float* int8scale ) */
	.text
	.align 5
#ifdef __APPLE__
	.global _sgemm_8x8_pack_fix8
_sgemm_8x8_pack_fix8:
#else
	.global sgemm_8x8_pack_fix8
sgemm_8x8_pack_fix8:
#endif
	ldr INT8SCALE, [INT8SCALE_ADDR]
	lsl LDC, LDC, #2
	mov CBK, C
	dup VSRC_4S_SCALE, INT8SCALE
	sxtw LDCX, LDC

	cbz L, __END

	ld1 {VSRC_4S_C0, VSRC_4S_C8}, [C], LDCX
	fcvtzs VSRC_4S_C0, VSRC_4S_C0, #FRACTIONBX2
	ld1 {VSRC_4S_C1, VSRC_4S_C9}, [C], LDCX
	fcvtzs VSRC_4S_C8, VSRC_4S_C8, #FRACTIONBX2
	fcvtzs VSRC_4S_C1, VSRC_4S_C1, #FRACTIONBX2
	ld1 {VSRC_4S_C2, VSRC_4S_CA}, [C], LDCX
	fcvtzs VSRC_4S_C9, VSRC_4S_C9, #FRACTIONBX2
	fcvtzs VSRC_4S_C2, VSRC_4S_C2, #FRACTIONBX2
	ld1 {VSRC_4S_C3, VSRC_4S_CB}, [C], LDCX
	fcvtzs VSRC_4S_CA, VSRC_4S_CA, #FRACTIONBX2
	fcvtzs VSRC_4S_C3, VSRC_4S_C3, #FRACTIONBX2
	ld1 {VSRC_4S_C4, VSRC_4S_CC}, [C], LDCX
	fcvtzs VSRC_4S_CB, VSRC_4S_CB, #FRACTIONBX2
	fcvtzs VSRC_4S_C4, VSRC_4S_C4, #FRACTIONBX2
	ld1 {VSRC_4S_C5, VSRC_4S_CD}, [C], LDCX
	fcvtzs VSRC_4S_CC, VSRC_4S_CC, #FRACTIONBX2
	fcvtzs VSRC_4S_C5, VSRC_4S_C5, #FRACTIONBX2
	ld1 {VSRC_4S_C6, VSRC_4S_CE}, [C], LDCX
	fcvtzs VSRC_4S_CD, VSRC_4S_CD, #FRACTIONBX2
	fcvtzs VSRC_4S_C6, VSRC_4S_C6, #FRACTIONBX2
	ld1 {VSRC_4S_C7, VSRC_4S_CF}, [C]
	fcvtzs VSRC_4S_CE, VSRC_4S_CE, #FRACTIONBX2
	prfm PLDL1KEEP, [A, #8]
	fcvtzs VSRC_4S_C7, VSRC_4S_C7, #FRACTIONBX2
	fcvtzs VSRC_4S_CF, VSRC_4S_CF, #FRACTIONBX2

__LOOP:
	ld1 {VSRC_8B_A}, [A], #8
	subs L, L, #1
	ld1 {VSRC_4H_B0, VSRC_4H_B1}, [B], #16

	sxtl VSRC_8H_A, VSRC_8B_A

	sxtl VSRC_4S_A0, VSRC_4H_A
	sxtl2 VSRC_4S_A1, VSRC_8H_A
	
	scvtf VSRC_4S_A0, VSRC_4S_A0
	scvtf VSRC_4S_A1, VSRC_4S_A1

	fmul VSRC_4S_A0, VSRC_4S_A0, VSRC_4S_SCALE
	fmul VSRC_4S_A1, VSRC_4S_A1, VSRC_4S_SCALE

	fcvtzs VSRC_4S_A0, VSRC_4S_A0, #FRACTION
	fcvtzs VSRC_4S_A1, VSRC_4S_A1, #FRACTION

	sqxtn VSRC_4H_A0, VSRC_4S_A0
	sqxtn VSRC_4H_A1, VSRC_4S_A1
	
	smlal VSRC_4S_C0, VSRC_4H_B0, VSRC_4H_A0_0
	smlal VSRC_4S_C1, VSRC_4H_B0, VSRC_4H_A0_1
	smlal VSRC_4S_C2, VSRC_4H_B0, VSRC_4H_A0_2
	smlal VSRC_4S_C3, VSRC_4H_B0, VSRC_4H_A0_3

	prfm PLDL1KEEP, [A, #8]
	smlal VSRC_4S_C4, VSRC_4H_B0, VSRC_4H_A1_0
	smlal VSRC_4S_C5, VSRC_4H_B0, VSRC_4H_A1_1
	smlal VSRC_4S_C6, VSRC_4H_B0, VSRC_4H_A1_2
	smlal VSRC_4S_C7, VSRC_4H_B0, VSRC_4H_A1_3

	prfm PLDL1KEEP, [B, #16]
	smlal VSRC_4S_C8, VSRC_4H_B1, VSRC_4H_A0_0
	smlal VSRC_4S_C9, VSRC_4H_B1, VSRC_4H_A0_1
	smlal VSRC_4S_CA, VSRC_4H_B1, VSRC_4H_A0_2
	smlal VSRC_4S_CB, VSRC_4H_B1, VSRC_4H_A0_3

	smlal VSRC_4S_CC, VSRC_4H_B1, VSRC_4H_A1_0
	smlal VSRC_4S_CD, VSRC_4H_B1, VSRC_4H_A1_1
	smlal VSRC_4S_CE, VSRC_4H_B1, VSRC_4H_A1_2
	smlal VSRC_4S_CF, VSRC_4H_B1, VSRC_4H_A1_3

	cbnz L, __LOOP

	scvtf VSRC_4S_C0, VSRC_4S_C0, #FRACTIONBX2
	scvtf VSRC_4S_C8, VSRC_4S_C8, #FRACTIONBX2
	st1 {VSRC_4S_C0, VSRC_4S_C8}, [CBK], LDCX

	scvtf VSRC_4S_C1, VSRC_4S_C1, #FRACTIONBX2
	scvtf VSRC_4S_C9, VSRC_4S_C9, #FRACTIONBX2
	st1 {VSRC_4S_C1, VSRC_4S_C9}, [CBK], LDCX

	scvtf VSRC_4S_C2, VSRC_4S_C2, #FRACTIONBX2
	scvtf VSRC_4S_CA, VSRC_4S_CA, #FRACTIONBX2
	st1 {VSRC_4S_C2, VSRC_4S_CA}, [CBK], LDCX

	scvtf VSRC_4S_C3, VSRC_4S_C3, #FRACTIONBX2
	scvtf VSRC_4S_CB, VSRC_4S_CB, #FRACTIONBX2
	st1 {VSRC_4S_C3, VSRC_4S_CB}, [CBK], LDCX

	scvtf VSRC_4S_C4, VSRC_4S_C4, #FRACTIONBX2
	scvtf VSRC_4S_CC, VSRC_4S_CC, #FRACTIONBX2
	st1 {VSRC_4S_C4, VSRC_4S_CC}, [CBK], LDCX

	scvtf VSRC_4S_C5, VSRC_4S_C5, #FRACTIONBX2
	scvtf VSRC_4S_CD, VSRC_4S_CD, #FRACTIONBX2
	st1 {VSRC_4S_C5, VSRC_4S_CD}, [CBK], LDCX

	scvtf VSRC_4S_C6, VSRC_4S_C6, #FRACTIONBX2
	scvtf VSRC_4S_CE, VSRC_4S_CE, #FRACTIONBX2
	st1 {VSRC_4S_C6, VSRC_4S_CE}, [CBK], LDCX

	scvtf VSRC_4S_C7, VSRC_4S_C7, #FRACTIONBX2
	scvtf VSRC_4S_CF, VSRC_4S_CF, #FRACTIONBX2
	st1 {VSRC_4S_C7, VSRC_4S_CF}, [CBK]

__END:
	ret

#else

#define STACK_SIZE       512

/* RSV [r4~r9,fp] */
/**************in param**************/
#define L 		 r0
#define A		 r1
#define B                r2
#define C                r3

/********** Backup R Regs ***********/
#define LDC              r4
#define VST              r5

/************ Stack Param ***********/
/* fp <--> r11 */
#ifdef __ARM_PCS_VFP  /*float-abi = hard*/

#define ST_LDC    [fp, #0]

#else /*float-abi = softfp*/

#define ST_LDC    [fp, #0]

#endif

/************ Vector Regs ***********/
/* RSV Q0~Q7 */
#define VSRC_4H_A0     d0//V0.4H
#define VSRC_4H_A0_0   d0[0]
#define VSRC_4H_A0_1   d0[1]
#define VSRC_4H_A0_2   d0[0]
#define VSRC_4H_A0_3   d0[1]

#define VSRC_4H_A1     d1//V1.4H
#define VSRC_4H_A1_0   d1[0]
#define VSRC_4H_A1_1   d1[1]
#define VSRC_4H_A1_2   d1[0]
#define VSRC_4H_A1_3   d1[1]

#define VSRC_4H_B0     d2//V2.4H
#define VSRC_4H_B1     d3//V3.4H

#define VSRC_4S_C0     q2//V4.4S
#define VSRC_4S_C8     q3//V5.4S

#define VSRC_4S_C1     q4//V6.4S
#define VSRC_4S_C9     q5//V7.4S

#define VSRC_4S_C2     q6//V16.4S
#define VSRC_4S_CA     q7//V17.4S

#define VSRC_4S_C3     q8//V18.4S
#define VSRC_4S_CB     q9//V19.4S

#define VSRC_4S_C4     q10//V20.4S
#define VSRC_4S_CC     q11

#define VSRC_4S_C5     q12//V22.4S
#define VSRC_4S_CD     q13

#define VSRC_4S_C6     q14//V24.4S
#define VSRC_4S_CE     q15//V25.4S

#define VSRC_4S_C7     q2//V26.4S ---- resuse C0
#define VSRC_4S_CF     q3//V27.4S ---- resuse C8

/************ Stack fp Area *********/
#define  STACK_START  [fp, #-524] // -512-12

#define  ST_C         [fp, #-520] //size 4

#define  ST_4S_C7     [fp, #-488] // VST size 32( ST_4S_C7, ST_4S_CF)

#define  STACK_END    [fp, #-140] // -128-12

#define  ST_Q0_Q8     STACK_END

/*
----------------------------------------------------------------------------------------------
            |                                                           |          ^
            |                                                           |          ^
            |                                                           |          ^
NEW_SP(TOP)-|--------------L ADDR----------------|-->[fp - 512 - 12] ---|--------PUSH BASE---
            |				   	 |                      |
            |	         (512-128) 	         |                      |
            |				   	 |                      |
FP - 140----|------------RSV(128)---STACK_END----|    STACK_SIZE(512)   |
            |	          	 		 |                      |
            |		 s0~s31    	         |                      |
            |			 		 |                      |
PUSH_SP-----|------------------------------------|-----------------------
            |                                    |
            |	     (R4~R5, FP) 12 Bytes        |
            |                                    |
0LD_SP FP --|------------------------------------|
            |          PARM_0(FP+ 0)             |
            |          PARM_1(FP+ 4)             |
            |          PARM_2(FP+ 8)             |
            |          PARM_3(FP+12)             |
            |               ...                  |
---------------------------H ADDR------------------------------------------------------------------
ABI: hard    r0 r1 r2 r3  [fp,#0]  [fp,#4]  [s0]      [s0]      [fp,#8]   [fp,#12]  [fp,#16] [fp,#20]
ABI: softfp  r0 r1 r2 r3  [fp,#0]  [fp,#4]  [fp,#8]   [fp,#12]  [fp,#16]  [fp,#20]
*/

/* void sgemm_8x8_pack_fix8( int L, char *a, short *b, float *c, int ldc, float int8scale ) */
	.text
	.align 5
#ifdef __APPLE__
	.global _sgemm_8x8_pack_fix8
_sgemm_8x8_pack_fix8:
#else
	.global sgemm_8x8_pack_fix8
sgemm_8x8_pack_fix8:
#endif
	push {r4-r5, fp}
	add fp, sp, #12
	sub sp, sp, #STACK_SIZE

	sub r4, fp, #140   /* [fp, -140] */
	vstm r4, {s0-s31}

	str C, ST_C        /* backup C into ST_C */
	ldr LDC, ST_LDC    /* load LDC param from ST_LDC */
	lsl LDC, LDC, #2

	cmp L, #0
	beq __END

	vld1.32 {VSRC_4S_C0, VSRC_4S_C8}, [C], LDC
	vcvt.s32.f32 VSRC_4S_C0, VSRC_4S_C0, #FRACTIONBX2
	vld1.32 {VSRC_4S_C1, VSRC_4S_C9}, [C], LDC
	vcvt.s32.f32 VSRC_4S_C8, VSRC_4S_C8, #FRACTIONBX2
	vcvt.s32.f32 VSRC_4S_C1, VSRC_4S_C1, #FRACTIONBX2
	vld1.32 {VSRC_4S_C2, VSRC_4S_CA}, [C], LDC
	vcvt.s32.f32 VSRC_4S_C9, VSRC_4S_C9, #FRACTIONBX2
	vcvt.s32.f32 VSRC_4S_C2, VSRC_4S_C2, #FRACTIONBX2
	vld1.32 {VSRC_4S_C3, VSRC_4S_CB}, [C], LDC
	vcvt.s32.f32 VSRC_4S_CA, VSRC_4S_CA, #FRACTIONBX2
	vpush {VSRC_4S_C0, VSRC_4S_C8}      // C7 resuse C0 CF resuse C8
	vcvt.s32.f32 VSRC_4S_C3, VSRC_4S_C3, #FRACTIONBX2
	vld1.32 {VSRC_4S_C4, VSRC_4S_CC}, [C], LDC
	vcvt.s32.f32 VSRC_4S_CB, VSRC_4S_CB, #FRACTIONBX2
	vcvt.s32.f32 VSRC_4S_C4, VSRC_4S_C4, #FRACTIONBX2
	vld1.32 {VSRC_4S_C5, VSRC_4S_CD}, [C], LDC
	vcvt.s32.f32 VSRC_4S_CC, VSRC_4S_CC, #FRACTIONBX2
	vcvt.s32.f32 VSRC_4S_C5, VSRC_4S_C5, #FRACTIONBX2
	vld1.32 {VSRC_4S_C6, VSRC_4S_CE}, [C], LDC
	vcvt.s32.f32 VSRC_4S_CD, VSRC_4S_CD, #FRACTIONBX2

	sub VST, fp, #488 //ST_4S_C7

	vcvt.s32.f32 VSRC_4S_C6, VSRC_4S_C6, #FRACTIONBX2
	vld1.32 {VSRC_4S_C7, VSRC_4S_CF}, [C] // C7 resuse C0 CF resuse C8
	vcvt.s32.f32 VSRC_4S_CE, VSRC_4S_CE, #FRACTIONBX2
	pld [A, #16]
	vcvt.s32.f32 VSRC_4S_C7, VSRC_4S_C7, #FRACTIONBX2
	vcvt.s32.f32 VSRC_4S_CF, VSRC_4S_CF, #FRACTIONBX2
	vst1.32 {VSRC_4S_C7, VSRC_4S_CF}, [VST]

__LOOP:
	vld1.16 {VSRC_4H_A0, VSRC_4H_A1}, [A]!
	subs L, L, #1
	vld1.16 {VSRC_4H_B0, VSRC_4H_B1}, [B]!

	vrev64.32 VSRC_4H_A0, VSRC_4H_A0

	vpop {VSRC_4S_C0, VSRC_4S_C8}

	vmlal.s16 VSRC_4S_C2, VSRC_4H_B0, VSRC_4H_A0_2
	vmlal.s16 VSRC_4S_C3, VSRC_4H_B0, VSRC_4H_A0_3
	vmlal.s16 VSRC_4S_CA, VSRC_4H_B1, VSRC_4H_A0_2
	vmlal.s16 VSRC_4S_CB, VSRC_4H_B1, VSRC_4H_A0_3

	vrev64.32 VSRC_4H_A0, VSRC_4H_A0

	vmlal.s16 VSRC_4S_C1, VSRC_4H_B0, VSRC_4H_A0_1
	vmlal.s16 VSRC_4S_C9, VSRC_4H_B1, VSRC_4H_A0_1
	vmlal.s16 VSRC_4S_C0, VSRC_4H_B0, VSRC_4H_A0_0
	vmlal.s16 VSRC_4S_C8, VSRC_4H_B1, VSRC_4H_A0_0

	vpush {VSRC_4S_C0, VSRC_4S_C8}
	pld [A, #16]
	vmlal.s16 VSRC_4S_C4, VSRC_4H_B0, VSRC_4H_A1_0
	vmlal.s16 VSRC_4S_C5, VSRC_4H_B0, VSRC_4H_A1_1
	vmlal.s16 VSRC_4S_CC, VSRC_4H_B1, VSRC_4H_A1_0
	vmlal.s16 VSRC_4S_CD, VSRC_4H_B1, VSRC_4H_A1_1

	vld1.32 {VSRC_4S_C7, VSRC_4S_CF}, [VST]
	vrev64.32 VSRC_4H_A1, VSRC_4H_A1

	pld [B, #16]
	vmlal.s16 VSRC_4S_C6, VSRC_4H_B0, VSRC_4H_A1_2
	vmlal.s16 VSRC_4S_CE, VSRC_4H_B1, VSRC_4H_A1_2
	vmlal.s16 VSRC_4S_C7, VSRC_4H_B0, VSRC_4H_A1_3 // C7 resuse C0
	vmlal.s16 VSRC_4S_CF, VSRC_4H_B1, VSRC_4H_A1_3 // CF resuse C8

	vst1.32 {VSRC_4S_C7, VSRC_4S_CF}, [VST]

	cmp L, #0
	bne __LOOP

	ldr C, ST_C
	vpop {VSRC_4S_C0, VSRC_4S_C8}

	vcvt.f32.s32 VSRC_4S_C0, VSRC_4S_C0, #FRACTIONBX2
	vcvt.f32.s32 VSRC_4S_C8, VSRC_4S_C8, #FRACTIONBX2
	vst1.32 {VSRC_4S_C0, VSRC_4S_C8}, [C], LDC

	vcvt.f32.s32 VSRC_4S_C1, VSRC_4S_C1, #FRACTIONBX2
	vcvt.f32.s32 VSRC_4S_C9, VSRC_4S_C9, #FRACTIONBX2
	vst1.32 {VSRC_4S_C1, VSRC_4S_C9}, [C], LDC

	vcvt.f32.s32 VSRC_4S_C2, VSRC_4S_C2, #FRACTIONBX2
	vcvt.f32.s32 VSRC_4S_CA, VSRC_4S_CA, #FRACTIONBX2
	vst1.32 {VSRC_4S_C2, VSRC_4S_CA}, [C], LDC

	vld1.32 {VSRC_4S_C7, VSRC_4S_CF}, [VST]

	vcvt.f32.s32 VSRC_4S_C3, VSRC_4S_C3, #FRACTIONBX2
	vcvt.f32.s32 VSRC_4S_CB, VSRC_4S_CB, #FRACTIONBX2
	vst1.32 {VSRC_4S_C3, VSRC_4S_CB}, [C], LDC

	vcvt.f32.s32 VSRC_4S_C4, VSRC_4S_C4, #FRACTIONBX2
	vcvt.f32.s32 VSRC_4S_CC, VSRC_4S_CC, #FRACTIONBX2
	vst1.32 {VSRC_4S_C4, VSRC_4S_CC}, [C], LDC

	vcvt.f32.s32 VSRC_4S_C5, VSRC_4S_C5, #FRACTIONBX2
	vcvt.f32.s32 VSRC_4S_CD, VSRC_4S_CD, #FRACTIONBX2
	vst1.32 {VSRC_4S_C5, VSRC_4S_CD}, [C], LDC

	vcvt.f32.s32 VSRC_4S_C6, VSRC_4S_C6, #FRACTIONBX2
	vcvt.f32.s32 VSRC_4S_CE, VSRC_4S_CE, #FRACTIONBX2
	vst1.32 {VSRC_4S_C6, VSRC_4S_CE}, [C], LDC

	vcvt.f32.s32 VSRC_4S_C7, VSRC_4S_C7, #FRACTIONBX2
	vcvt.f32.s32 VSRC_4S_CF, VSRC_4S_CF, #FRACTIONBX2
	vst1.32 {VSRC_4S_C7, VSRC_4S_CF}, [C]

__END:
	sub r4, fp, #140
	vldm r4, {s0-s31}
	sub sp, fp, #12
	pop {r4-r5, fp}
	bx lr
#endif
