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

#ifndef PLCRASH_ASYNC_IMAGE_LIST_H
#define PLCRASH_ASYNC_IMAGE_LIST_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <libkern/OSAtomic.h>
#include <stdbool.h>

#include "ApigeePLCrashAsyncMachOImage.h"

/*
 * NOTE: We keep this code C-compatible for backwards-compatibility purposes. If the entirity
 * of the codebase migrates to C/C++/Objective-C++, we can drop the C compatibility support
 * used here.
 */
#ifdef __cplusplus
#include "ApigeePLCrashAsyncLinkedList.hpp"
#endif
    
typedef struct apigee_plcrash_async_image apigee_plcrash_async_image_t;

/**
 * @internal
 * @ingroup plcrash_async_image
 *
 * Async-safe binary image list element.
 */
struct apigee_plcrash_async_image {
    /** The binary image. */
    apigee_plcrash_async_macho_t macho_image;

    /** A borrowed, circular reference to the backing list node. */
#ifdef __cplusplus
    apigee::plcrash::async::async_list<apigee_plcrash_async_image_t *>::node *_node;
#else
    void *_node;
#endif
};

/**
 * @internal
 * @ingroup plcrash_async_image
 *
 * Async-safe binary image list. May be used to iterate over the binary images currently
 * available in-process.
 */
typedef struct apigee_plcrash_async_image_list {
    /** The Mach task in which all Mach-O images can be found */
    mach_port_t task;

    /** The backing list */
#ifdef __cplusplus
    apigee::plcrash::async::async_list<apigee_plcrash_async_image_t *> *_list;
#else
    void *_list;
#endif
} apigee_plcrash_async_image_list_t;

void apigee_plcrash_nasync_image_list_init (apigee_plcrash_async_image_list_t *list, mach_port_t task);
void apigee_plcrash_nasync_image_list_free (apigee_plcrash_async_image_list_t *list);
void apigee_plcrash_nasync_image_list_append (apigee_plcrash_async_image_list_t *list, pl_vm_address_t header, const char *name);
void apigee_plcrash_nasync_image_list_remove (apigee_plcrash_async_image_list_t *list, pl_vm_address_t header);

void apigee_plcrash_async_image_list_set_reading (apigee_plcrash_async_image_list_t *list, bool enable);

apigee_plcrash_async_image_t *apigee_plcrash_async_image_containing_address (apigee_plcrash_async_image_list_t *list, pl_vm_address_t address);
apigee_plcrash_async_image_t *apigee_plcrash_async_image_list_next (apigee_plcrash_async_image_list_t *list, apigee_plcrash_async_image_t *current);
    
#ifdef __cplusplus
}
#endif

#endif /* PLCRASH_ASYNC_IMAGE_LIST_H */
