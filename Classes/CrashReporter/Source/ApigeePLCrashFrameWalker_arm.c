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

#import "ApigeePLCrashFrameWalker.h"
#import "ApigeePLCrashAsync.h"

#import <signal.h>
#import <assert.h>
#import <stdlib.h>

#ifdef __arm__

#define RETGEN(name, type, uap, result) {\
    *result = (uap->uc_mcontext->__ ## type . __ ## name); \
    return Apigee_PLFRAME_ESUCCESS; \
}

// PLFrameWalker API
Apigee_plframe_error_t Apigee_plframe_cursor_init (Apigee_plframe_cursor_t *cursor, ucontext_t *uap) {
    cursor->uap = uap;
    cursor->init_frame = true;
    cursor->fp[0] = NULL;
    
    return Apigee_PLFRAME_ESUCCESS;
}


// PLFrameWalker API
Apigee_plframe_error_t Apigee_plframe_cursor_thread_init (Apigee_plframe_cursor_t *cursor, thread_t thread) {
    kern_return_t kr;
    ucontext_t *uap;
    
    /* Perform basic initialization */
    uap = &cursor->_uap_data;
    uap->uc_mcontext = (void *) &cursor->_mcontext_data;
    
    /* Zero the signal mask */
    sigemptyset(&uap->uc_sigmask);
    
    /* Fetch the thread states */
    mach_msg_type_number_t state_count;
    
    /* Sanity check */
    assert(sizeof(cursor->_mcontext_data.__ss) == sizeof(arm_thread_state_t));
    assert(sizeof(cursor->_mcontext_data.__es) == sizeof(arm_exception_state_t));
    assert(sizeof(cursor->_mcontext_data.__fs) == sizeof(arm_vfp_state_t));
    
    // thread state
    state_count = ARM_THREAD_STATE_COUNT;
    kr = thread_get_state(thread, ARM_THREAD_STATE, (thread_state_t) &cursor->_mcontext_data.__ss, &state_count);
    if (kr != KERN_SUCCESS) {
        Apigee_PLCF_DEBUG("Fetch of arm thread state failed with mach error: %d", kr);
        return Apigee_PLFRAME_INTERNAL;
    }
    
    // floating point state
    state_count = ARM_VFP_STATE_COUNT;
    kr = thread_get_state(thread, ARM_VFP_STATE, (thread_state_t) &cursor->_mcontext_data.__fs, &state_count);
    if (kr != KERN_SUCCESS) {
        Apigee_PLCF_DEBUG("Fetch of arm vfp state failed with mach error: %d", kr);
        return Apigee_PLFRAME_INTERNAL;
    }
    
    // exception state
    state_count = ARM_EXCEPTION_STATE_COUNT;
    kr = thread_get_state(thread, ARM_EXCEPTION_STATE, (thread_state_t) &cursor->_mcontext_data.__es, &state_count);
    if (kr != KERN_SUCCESS) {
        Apigee_PLCF_DEBUG("Fetch of ARM exception state failed with mach error: %d", kr);
        return Apigee_PLFRAME_INTERNAL;
    }
    
    /* Perform standard initialization */
    Apigee_plframe_cursor_init(cursor, uap);
    
    return Apigee_PLFRAME_ESUCCESS;
}


// PLFrameWalker API
Apigee_plframe_error_t Apigee_plframe_cursor_next (Apigee_plframe_cursor_t *cursor) {
    kern_return_t kr;
    void *prevfp = cursor->fp[0];

    /* Fetch the next stack address */
    if (cursor->init_frame) {
        /* The first frame is already available, so there's nothing to do */
        cursor->init_frame = false;
        return Apigee_PLFRAME_ESUCCESS;
    } else {
        if (cursor->fp[0] == NULL) {
            /* No frame data has been loaded, fetch it from register state */
            kr = Apigee_plframe_read_addr((void *) cursor->uap->uc_mcontext->__ss.__r[7], cursor->fp, sizeof(cursor->fp));
        } else {
            /* Frame data loaded, walk the stack */
            kr = Apigee_plframe_read_addr(cursor->fp[0], cursor->fp, sizeof(cursor->fp));
        }
    }
    
    /* Was the read successful? */
    if (kr != KERN_SUCCESS)
        return Apigee_PLFRAME_EBADFRAME;
    
    /* Check for completion */
    if (cursor->fp[0] == NULL)
        return Apigee_PLFRAME_ENOFRAME;
    
    /* Is the stack growing in the right direction? */
    if (!cursor->init_frame && prevfp > cursor->fp[0])
        return Apigee_PLFRAME_EBADFRAME;
    
    /* New frame fetched */
    return Apigee_PLFRAME_ESUCCESS;
}


// PLFrameWalker API
Apigee_plframe_error_t Apigee_plframe_get_reg (Apigee_plframe_cursor_t *cursor, Apigee_plframe_regnum_t regnum, Apigee_plframe_greg_t *reg) {
    ucontext_t *uap = cursor->uap;
    
    /* Supported register for this context state? */
    if (cursor->fp[0] != NULL) {
        if (regnum == Apigee_PLFRAME_ARM_PC) {
            *reg = (Apigee_plframe_greg_t) cursor->fp[1];
            return Apigee_PLFRAME_ESUCCESS;
        }
        
        return Apigee_PLFRAME_ENOTSUP;
    }
    
    switch (regnum) {
        case Apigee_PLFRAME_ARM_R0:
        case Apigee_PLFRAME_ARM_R1:
        case Apigee_PLFRAME_ARM_R2:
        case Apigee_PLFRAME_ARM_R3:
        case Apigee_PLFRAME_ARM_R4:
        case Apigee_PLFRAME_ARM_R5:
        case Apigee_PLFRAME_ARM_R6:
        case Apigee_PLFRAME_ARM_R7:
        case Apigee_PLFRAME_ARM_R8:
        case Apigee_PLFRAME_ARM_R9:
        case Apigee_PLFRAME_ARM_R10:
        case Apigee_PLFRAME_ARM_R11:
        case Apigee_PLFRAME_ARM_R12:
            // Map enum to actual register index */
            RETGEN(r[regnum - Apigee_PLFRAME_ARM_R0], ss, uap, reg);

        case Apigee_PLFRAME_ARM_SP:
            RETGEN(sp, ss, uap, reg);

        case Apigee_PLFRAME_ARM_LR:
            RETGEN(lr, ss, uap, reg);

        case Apigee_PLFRAME_ARM_PC:
            RETGEN(pc, ss, uap, reg);
            
        case Apigee_PLFRAME_ARM_CPSR:
            RETGEN(cpsr, ss, uap, reg);
            
        default:
            return Apigee_PLFRAME_ENOTSUP;
    }

    return Apigee_PLFRAME_ENOTSUP;
}


// PLFrameWalker API
Apigee_plframe_error_t Apigee_plframe_get_freg (Apigee_plframe_cursor_t *cursor, Apigee_plframe_regnum_t regnum, Apigee_plframe_fpreg_t *fpreg) {
    return Apigee_PLFRAME_ENOTSUP;
}


// PLFrameWalker API
const char *Apigee_plframe_get_regname (Apigee_plframe_regnum_t regnum) {
    switch (regnum) {
        case Apigee_PLFRAME_ARM_R0:
            return "r0";
        case Apigee_PLFRAME_ARM_R1:
            return "r1";
        case Apigee_PLFRAME_ARM_R2:
            return "r2";
        case Apigee_PLFRAME_ARM_R3:
            return "r3";
        case Apigee_PLFRAME_ARM_R4:
            return "r4";
        case Apigee_PLFRAME_ARM_R5:
            return "r5";
        case Apigee_PLFRAME_ARM_R6:
            return "r6";
        case Apigee_PLFRAME_ARM_R7:
            return "r7";
        case Apigee_PLFRAME_ARM_R8:
            return "r8";
        case Apigee_PLFRAME_ARM_R9:
            return "r9";
        case Apigee_PLFRAME_ARM_R10:
            return "r10";
        case Apigee_PLFRAME_ARM_R11:
            return "r11";
        case Apigee_PLFRAME_ARM_R12:
            return "r12";
            
        case Apigee_PLFRAME_ARM_SP:
            return "sp";
            
        case Apigee_PLFRAME_ARM_LR:
            return "lr";
            
        case Apigee_PLFRAME_ARM_PC:
            return "pc";

        case Apigee_PLFRAME_ARM_CPSR:
            return "cpsr";
            
        default:
            // Unsupported register
            break;
    }
    
    /* Unsupported register is an implementation error (checked in unit tests) */
    Apigee_PLCF_DEBUG("Missing register name for register id: %d", regnum);
    abort();
}


#endif /* __arm__ */
