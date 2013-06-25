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

#ifdef __i386__

// 32-bit
typedef uintptr_t Apigee_plframe_pdef_greg_t;
typedef uintptr_t Apigee_plframe_pdef_fpreg_t;

// Data we'll read off the stack frame
#define Apigee_PLFRAME_PDEF_STACKFRAME_LEN 2

/**
 * @internal
 * x86 registers, as defined by the System V ABI, IA32 Supplement. 
 */
typedef enum {
    /*
     * General
     */
    
    /** Return value */
    Apigee_PLFRAME_X86_EAX = 0,

    /** Dividend register */
    Apigee_PLFRAME_X86_EDX,

    /** Count register */
    Apigee_PLFRAME_X86_ECX,

    /** Local register variable */
    Apigee_PLFRAME_X86_EBX,
    
    /** Stack frame pointer */
    Apigee_PLFRAME_X86_EBP,

    /** Local register variable */
    Apigee_PLFRAME_X86_ESI,

    /** Local register variable */
    Apigee_PLFRAME_X86_EDI,

    /** Stack pointer */
    Apigee_PLFRAME_X86_ESP,

    /** Instruction pointer */
    Apigee_PLFRAME_X86_EIP,
    
    /** Flags */
    Apigee_PLFRAME_X86_EFLAGS,
    
    /* Scratcn */
    Apigee_PLFRAME_X86_TRAPNO,
    
    
    /*
     * Segment Registers
     */
    /** Segment register */
    Apigee_PLFRAME_X86_CS,
    
    /** Segment register */
    Apigee_PLFRAME_X86_DS,
    
    /** Segment register */
    Apigee_PLFRAME_X86_ES,
    
    /** Segment register */
    Apigee_PLFRAME_X86_FS,
    
    /** Segment register */
    Apigee_PLFRAME_X86_GS,

    Apigee_PLFRAME_PDEF_REG_IP = Apigee_PLFRAME_X86_EIP,
    
    /** Last register */
    Apigee_PLFRAME_PDEF_LAST_REG = Apigee_PLFRAME_X86_GS
} Apigee_plframe_x86_regnum_t;

#endif /* __i386__ */
