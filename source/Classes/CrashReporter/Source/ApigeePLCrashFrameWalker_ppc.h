/*
 * Author: Landon Fuller <landonf@plausiblelabs.com>
 *
 * Copyright (c) 2008-2009 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#ifdef __ppc__

// 32-bit
typedef uintptr_t Apigee_plframe_pdef_greg_t;
typedef uintptr_t Apigee_plframe_pdef_fpreg_t;

// Data we'll read off the stack frame
#define Apigee_PLFRAME_PDEF_STACKFRAME_LEN 3

/**
 * @internal
 * PPC Registers
 */
typedef enum {
    /** Instruction address register (PC) */
    Apigee_PLFRAME_PPC_SRR0 = 0,
    
    /** Machine state register (supervisor) */
    Apigee_PLFRAME_PPC_SRR1,
    
    Apigee_PLFRAME_PPC_DAR,
    Apigee_PLFRAME_PPC_DSISR,
    
    Apigee_PLFRAME_PPC_R0,
    Apigee_PLFRAME_PPC_R1,
    Apigee_PLFRAME_PPC_R2,
    Apigee_PLFRAME_PPC_R3,
    Apigee_PLFRAME_PPC_R4,
    Apigee_PLFRAME_PPC_R5,
    Apigee_PLFRAME_PPC_R6,
    Apigee_PLFRAME_PPC_R7,
    Apigee_PLFRAME_PPC_R8,
    Apigee_PLFRAME_PPC_R9,
    Apigee_PLFRAME_PPC_R10,
    Apigee_PLFRAME_PPC_R11,
    Apigee_PLFRAME_PPC_R12,
    Apigee_PLFRAME_PPC_R13,
    Apigee_PLFRAME_PPC_R14,
    Apigee_PLFRAME_PPC_R15,
    Apigee_PLFRAME_PPC_R16,
    Apigee_PLFRAME_PPC_R17,
    Apigee_PLFRAME_PPC_R18,
    Apigee_PLFRAME_PPC_R19,
    Apigee_PLFRAME_PPC_R20,
    Apigee_PLFRAME_PPC_R21,
    Apigee_PLFRAME_PPC_R22,
    Apigee_PLFRAME_PPC_R23,
    Apigee_PLFRAME_PPC_R24,
    Apigee_PLFRAME_PPC_R25,
    Apigee_PLFRAME_PPC_R26,
    Apigee_PLFRAME_PPC_R27,
    Apigee_PLFRAME_PPC_R28,
    Apigee_PLFRAME_PPC_R29,
    Apigee_PLFRAME_PPC_R30,
    Apigee_PLFRAME_PPC_R31,

    /** Condition register */
    Apigee_PLFRAME_PPC_CR,
    
    /** User integer exception register */
    Apigee_PLFRAME_PPC_XER,

    /** Link register */
    Apigee_PLFRAME_PPC_LR,
    
    /** Count register */
    Apigee_PLFRAME_PPC_CTR,
    
    /** Vector save reigster */
    Apigee_PLFRAME_PPC_VRSAVE,

    
    Apigee_PLFRAME_PDEF_REG_IP = Apigee_PLFRAME_PPC_SRR0,
    
    /* Last register */
    Apigee_PLFRAME_PDEF_LAST_REG = Apigee_PLFRAME_PPC_VRSAVE
} Apigee_plframe_ppc_regnum_t;

#endif /* __ppc__ */
