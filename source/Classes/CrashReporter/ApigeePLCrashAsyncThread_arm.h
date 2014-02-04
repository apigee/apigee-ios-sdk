/*
 * Author: Landon Fuller <landonf@plausiblelabs.com>
 *
 * Copyright (c) 2008-2013 Plausible Labs Cooperative, Inc.
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

#ifndef PLCRASH_ASYNC_THREAD_ARM_H
#define PLCRASH_ASYNC_THREAD_ARM_H

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__arm__) || defined(__arm64__)

// Large enough for 64-bit or 32-bit
typedef uint64_t apigee_plcrash_pdef_greg_t;
typedef uint64_t apigee_plcrash_pdef_fpreg_t;

#endif /* __arm__ */

/**
 * @internal
 * Arm registers
 */
typedef enum {
    /*
     * General
     */
    
    /** Program counter (r15) */
    APIGEE_PLCRASH_ARM_PC = APIGEE_PLCRASH_REG_IP,
    
    /** Frame pointer */
    APIGEE_PLCRASH_ARM_R7 = APIGEE_PLCRASH_REG_FP,
    
    /* stack pointer (r13) */
    APIGEE_PLCRASH_ARM_SP = APIGEE_PLCRASH_REG_SP,

    APIGEE_PLCRASH_ARM_R0,
    APIGEE_PLCRASH_ARM_R1,
    APIGEE_PLCRASH_ARM_R2,
    APIGEE_PLCRASH_ARM_R3,
    APIGEE_PLCRASH_ARM_R4,
    APIGEE_PLCRASH_ARM_R5,
    APIGEE_PLCRASH_ARM_R6,
    // R7 is defined above
    APIGEE_PLCRASH_ARM_R8,
    APIGEE_PLCRASH_ARM_R9,
    APIGEE_PLCRASH_ARM_R10,
    APIGEE_PLCRASH_ARM_R11,
    APIGEE_PLCRASH_ARM_R12,
    
    /* link register (r14) */
    APIGEE_PLCRASH_ARM_LR,
    
    /** Current program status register */
    APIGEE_PLCRASH_ARM_CPSR,
    
    /** Last register */
    APIGEE_PLCRASH_ARM_LAST_REG = APIGEE_PLCRASH_ARM_CPSR
} apigee_plcrash_arm_regnum_t;
    
/**
 * @internal
 * ARM64 registers
 */
typedef enum {
    /*
     * General
     */
    
    /** Program counter */
    APIGEE_PLCRASH_ARM64_PC = APIGEE_PLCRASH_REG_IP,
    
    /** Frame pointer (x29) */
    APIGEE_PLCRASH_ARM64_FP = APIGEE_PLCRASH_REG_FP,
    
    /* stack pointer (x31) */
    APIGEE_PLCRASH_ARM64_SP = APIGEE_PLCRASH_REG_SP,
    
    APIGEE_PLCRASH_ARM64_X0,
    APIGEE_PLCRASH_ARM64_X1,
    APIGEE_PLCRASH_ARM64_X2,
    APIGEE_PLCRASH_ARM64_X3,
    APIGEE_PLCRASH_ARM64_X4,
    APIGEE_PLCRASH_ARM64_X5,
    APIGEE_PLCRASH_ARM64_X6,
    APIGEE_PLCRASH_ARM64_X7,
    APIGEE_PLCRASH_ARM64_X8,
    APIGEE_PLCRASH_ARM64_X9,
    APIGEE_PLCRASH_ARM64_X10,
    APIGEE_PLCRASH_ARM64_X11,
    APIGEE_PLCRASH_ARM64_X12,
    APIGEE_PLCRASH_ARM64_X13,
    APIGEE_PLCRASH_ARM64_X14,
    APIGEE_PLCRASH_ARM64_X15,
    APIGEE_PLCRASH_ARM64_X16,
    APIGEE_PLCRASH_ARM64_X17,
    APIGEE_PLCRASH_ARM64_X18,
    APIGEE_PLCRASH_ARM64_X19,
    APIGEE_PLCRASH_ARM64_X20,
    APIGEE_PLCRASH_ARM64_X21,
    APIGEE_PLCRASH_ARM64_X22,
    APIGEE_PLCRASH_ARM64_X23,
    APIGEE_PLCRASH_ARM64_X24,
    APIGEE_PLCRASH_ARM64_X25,
    APIGEE_PLCRASH_ARM64_X26,
    APIGEE_PLCRASH_ARM64_X27,
    APIGEE_PLCRASH_ARM64_X28,

    /* link register (x30) */
    APIGEE_PLCRASH_ARM64_LR,
    
    /** Current program status register */
    APIGEE_PLCRASH_ARM64_CPSR,
    
    /** Last register */
    APIGEE_PLCRASH_ARM64_LAST_REG = APIGEE_PLCRASH_ARM64_CPSR
} apigee_plcrash_arm64_regnum_t;

#ifdef __cplusplus
}
#endif

#endif /* PLCRASH_ASYNC_THREAD_ARM_H */
