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

#include "ApigeePLCrashFrameWalker.h"
#include "ApigeePLCrashAsync.h"
#include "ApigeePLCrashTestThread.h"

#include "ApigeePLCrashFrameStackUnwind.h"
#include "ApigeePLCrashFrameCompactUnwind.h"
#include "ApigeePLCrashFrameDWARFUnwind.h"

#include "ApigeePLCrashFeatureConfig.h"

#pragma mark Error Handling

/**
 * Return an error description for the given plframe_error_t.
 */
const char *apigee_plframe_strerror (apigee_plframe_error_t error) {
    switch (error) {
        case APIGEE_PLFRAME_ESUCCESS:
            return "No error";
        case APIGEE_PLFRAME_EUNKNOWN:
            return "Unknown error";
        case APIGEE_PLFRAME_ENOFRAME:
            return "No frames are available";
        case APIGEE_PLFRAME_EBADFRAME:
            return "Corrupted frame";
        case APIGEE_PLFRAME_ENOTSUP:
            return "Operation not supported";
        case APIGEE_PLFRAME_EINVAL:
            return "Invalid argument";
        case APIGEE_PLFRAME_INTERNAL:
            return "Internal error";
        case APIGEE_PLFRAME_EBADREG:
            return "Invalid register";
    }

    /* Should be unreachable */
    return "Unhandled error code";
}

#pragma mark Test Thread

/* A thread that exists just to give us a stack to iterate */
static void *test_stack_thr (void *arg) {
    plcrash_test_thread_t *args = arg;
    
    /* Acquire the lock and inform our caller that we're active */
    pthread_mutex_lock(&args->lock);
    pthread_cond_signal(&args->cond);
    
    /* Wait for a shut down request, and then drop the acquired lock immediately */
    pthread_cond_wait(&args->cond, &args->lock);
    pthread_mutex_unlock(&args->lock);
    
    return NULL;
}


/** Spawn a test thread that may be used as an iterable stack. (For testing only!) */
void apigee_plframe_test_thread_spawn (plcrash_test_thread_t *args) {
    /* Initialize the args */
    pthread_mutex_init(&args->lock, NULL);
    pthread_cond_init(&args->cond, NULL);
    
    /* Lock and start the thread */
    pthread_mutex_lock(&args->lock);
    pthread_create(&args->thread, NULL, test_stack_thr, args);
    pthread_cond_wait(&args->cond, &args->lock);
    pthread_mutex_unlock(&args->lock);
}

/** Stop a test thread. */
void apigee_plframe_test_thread_stop (plcrash_test_thread_t *args) {
    /* Signal the thread to exit */
    pthread_mutex_lock(&args->lock);
    pthread_cond_signal(&args->cond);
    pthread_mutex_unlock(&args->lock);
    
    /* Wait for exit */
    pthread_join(args->thread, NULL);
}

#pragma mark Frame Walking

/**
 * @internal
 * Shared initializer. Assumes that the initial frame has all registers available.
 *
 * @param cursor Cursor record to be initialized.
 * @param task The task from which @a uap was derived. All memory will be mapped from this task.
 * @param image_list The task's current image list. This is a borrowed reference, and must remain valid for the lifetime of the cursor.
 */
static void apigee_plframe_cursor_internal_init (apigee_plframe_cursor_t *cursor, task_t task, apigee_plcrash_async_image_list_t *image_list) {
    cursor->depth = 0;
    cursor->task = task;
    cursor->image_list = image_list;
    mach_port_mod_refs(mach_task_self(), cursor->task, MACH_PORT_RIGHT_SEND, 1);    
}

/**
 * Initialize the frame cursor using the provided thread state.
 *
 * @param cursor Cursor record to be initialized.
 * @param task The task from which @a uap was derived. All memory will be mapped from this task.
 * @param thread_state The thread state to use for cursor initialization.
 * @param image_list The task's current image list. This is a borrowed reference, and must remain valid for the lifetime of the cursor.
 *
 * @return Returns PLFRAME_ESUCCESS on success, or standard plframe_error_t code if an error occurs.
 *
 * @warn Callers must call plframe_cursor_free() on @a cursor to free any associated resources, even if initialization
 * fails.
 */
apigee_plframe_error_t apigee_plframe_cursor_init (apigee_plframe_cursor_t *cursor, task_t task, apigee_plcrash_async_thread_state_t *thread_state, apigee_plcrash_async_image_list_t *image_list) {
    apigee_plframe_cursor_internal_init(cursor, task, image_list);

    apigee_plcrash_async_memcpy(&cursor->frame.thread_state, thread_state, sizeof(cursor->frame.thread_state));

    return APIGEE_PLFRAME_ESUCCESS;
}

/**
 * Initialize the frame cursor by acquiring state from the provided mach thread. If the thread is not suspended,
 * the fetched state may be inconsistent.
 *
 * @param cursor Cursor record to be initialized.
 * @param task The task in which @a thread is running. All memory will be mapped from this task.
 * @param thread The thread to use for cursor initialization.
 * @param image_list The task's current image list. This is a borrowed reference, and must remain valid for the lifetime of the cursor.
 *
 * @return Returns PLFRAME_ESUCCESS on success, or standard plframe_error_t code if an error occurs.
 *
 * @warn Callers must call plframe_cursor_free() on @a cursor to free any associated resources, even if initialization
 * fails.
 */
apigee_plframe_error_t apigee_plframe_cursor_thread_init (apigee_plframe_cursor_t *cursor, task_t task, thread_t thread, apigee_plcrash_async_image_list_t *image_list) {
    /* Standard initialization */
    apigee_plframe_cursor_internal_init(cursor, task, image_list);
    
    return apigee_plcrash_async_thread_state_mach_thread_init(&cursor->frame.thread_state, thread);
}

/**
 * Fetch the next frame using the provided frame readers.
 *
 * @param cursor A cursor instance initialized with plframe_cursor_init();
 * @param readers Frame readers to be used to fetch the next frame. Each reader will be executed in the provided order until a valid frame is read.
 * @param reader_count The number of readers provided in @a readers.
 * @return Returns PLFRAME_ESUCCESS on success, PLFRAME_ENOFRAME is no additional frames are available, or a standard plframe_error_t code if an error occurs.
 */
apigee_plframe_error_t apigee_plframe_cursor_next_with_readers (apigee_plframe_cursor_t *cursor, apigee_plframe_cursor_frame_reader_t *readers[], size_t reader_count) {
    /* The first frame is already available via existing thread state. */
    if (cursor->depth == 0) {
        cursor->depth++;
        return APIGEE_PLFRAME_ESUCCESS;
    }
    
    /* A previous frame is only available if we're on the second frame */
    apigee_plframe_stackframe_t *prev_frame = NULL;
    if (cursor->depth >= 2)
        prev_frame = &cursor->prev_frame;
    
    /* Read in the next frame using the first successful frame reader. */
    apigee_plframe_stackframe_t frame;
    apigee_plframe_error_t ferr = APIGEE_PLFRAME_EINVAL; // default return value if reader_count is 0.
    
    for (size_t i = 0; i < reader_count; i++) {
        ferr = readers[i](cursor->task, cursor->image_list, &cursor->frame, prev_frame, &frame);
        if (ferr == APIGEE_PLFRAME_ESUCCESS)
            break;
    }
    
    if (ferr != APIGEE_PLFRAME_ESUCCESS) {
        return ferr;
    }

    /* Check for completion */
    if (!apigee_plcrash_async_thread_state_has_reg(&frame.thread_state, APIGEE_PLCRASH_REG_IP)) {
        PLCF_DEBUG("Missing expected IP value in successfully read frame");
        return APIGEE_PLFRAME_ENOFRAME;
    }
    
    /* A pc within the NULL page is a terminating frame */
    apigee_plcrash_greg_t ip = apigee_plcrash_async_thread_state_get_reg(&frame.thread_state, APIGEE_PLCRASH_REG_IP);
    if (ip <= PAGE_SIZE)
        return APIGEE_PLFRAME_ENOFRAME;
    
    /* Save the newly fetched frame */
    cursor->prev_frame = cursor->frame;
    cursor->frame = frame;
    cursor->depth++;
    
    return APIGEE_PLFRAME_ESUCCESS;
}

/**
 * Fetch the next frame.
 *
 * @param cursor A cursor instance initialized with plframe_cursor_init();
 * @return Returns PLFRAME_ESUCCESS on success, PLFRAME_ENOFRAME is no additional frames are available, or a standard plframe_error_t code if an error occurs.
 */
apigee_plframe_error_t apigee_plframe_cursor_next (apigee_plframe_cursor_t *cursor) {
    apigee_plframe_cursor_frame_reader_t *readers[] = {

#if PLCRASH_FEATURE_UNWIND_COMPACT
        apigee_plframe_cursor_read_compact_unwind,
#endif

#if PLCRASH_FEATURE_UNWIND_DWARF
        apigee_plframe_cursor_read_dwarf_unwind,
#endif

        apigee_plframe_cursor_read_frame_ptr
    };

    return apigee_plframe_cursor_next_with_readers(cursor, readers, sizeof(readers)/sizeof(readers[0]));
}


/**
 * Get a register value. Returns PLFRAME_ENOTSUP if the given register is unavailable within the current frame.
 *
 * @param cursor A cursor instance representing a valid frame, as initialized by plframe_cursor_next().
 * @param regnum The register to fetch from the current frame's state.
 * @param reg On success, will be set to the register's value.
 */
apigee_plframe_error_t apigee_plframe_cursor_get_reg (apigee_plframe_cursor_t *cursor, apigee_plcrash_regnum_t regnum, apigee_plcrash_greg_t *reg) {
    /* Verify that the register is available */
    if (!apigee_plcrash_async_thread_state_has_reg(&cursor->frame.thread_state, regnum))
        return APIGEE_PLFRAME_ENOTSUP;

    /* Fetch from thread state */
    *reg = apigee_plcrash_async_thread_state_get_reg(&cursor->frame.thread_state, regnum);
    return APIGEE_PLFRAME_ESUCCESS;
}

/**
 * Get a register's name.
 *
 * @param cursor A cursor instance initialized with plframe_cursor_init();
 * @param regnum The register number for which a name should be returned.
 */
char const *apigee_plframe_cursor_get_regname (apigee_plframe_cursor_t *cursor, apigee_plcrash_regnum_t regnum) {
    return apigee_plcrash_async_thread_state_get_reg_name(&cursor->frame.thread_state, regnum);
}

/**
 * Get the total number of registers supported by the @a cursor's target thread.
 *
 * @param cursor The target cursor.
 */
size_t apigee_plframe_cursor_get_regcount (apigee_plframe_cursor_t *cursor) {
    return apigee_plcrash_async_thread_state_get_reg_count(&cursor->frame.thread_state);
}

/**
 * Free any resources associated with the frame cursor.
 *
 * @param cursor Cursor record to be freed
 */
void apigee_plframe_cursor_free(apigee_plframe_cursor_t *cursor) {
    if (cursor->task != MACH_PORT_NULL)
        mach_port_mod_refs(mach_task_self(), cursor->task, MACH_PORT_RIGHT_SEND, -1);
}
