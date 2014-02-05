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

#import <stdlib.h>
#import <fcntl.h>
#import <errno.h>
#import <string.h>
#import <stdbool.h>
#import <dlfcn.h>

#import <sys/sysctl.h>
#import <sys/time.h>

#import <mach-o/dyld.h>

#import <libkern/OSAtomic.h>

#import "ApigeePLCrashReport.h"
#import "ApigeePLCrashLogWriter.h"
#import "ApigeePLCrashLogWriterEncoding.h"
#import "ApigeePLCrashAsyncSignalInfo.h"
#import "ApigeePLCrashAsyncSymbolication.h"

#import "ApigeePLCrashSysctl.h"
#import "ApigeePLCrashProcessInfo.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h> // For UIDevice
#endif

/**
 * @internal
 * Maximum number of frames that will be written to the crash report for a single thread. Used as a safety measure
 * to avoid overrunning our output limit when writing a crash report triggered by frame recursion.
 */
#define MAX_THREAD_FRAMES 512 // matches Apple's crash reporting on Snow Leopard

/**
 * @internal
 * Protobuf Field IDs, as defined in crashreport.proto
 */
enum {
    /** CrashReport.system_info */
    APIGEE_PLCRASH_PROTO_SYSTEM_INFO_ID = 1,

    /** CrashReport.system_info.operating_system */
    APIGEE_PLCRASH_PROTO_SYSTEM_INFO_OS_ID = 1,

    /** CrashReport.system_info.os_version */
    APIGEE_PLCRASH_PROTO_SYSTEM_INFO_OS_VERSION_ID = 2,

    /** CrashReport.system_info.architecture */
    APIGEE_PLCRASH_PROTO_SYSTEM_INFO_ARCHITECTURE_TYPE_ID = 3,

    /** CrashReport.system_info.timestamp */
    APIGEE_PLCRASH_PROTO_SYSTEM_INFO_TIMESTAMP_ID = 4,

    /** CrashReport.system_info.os_build */
    APIGEE_PLCRASH_PROTO_SYSTEM_INFO_OS_BUILD_ID = 5,

    /** CrashReport.app_info */
    APIGEE_PLCRASH_PROTO_APP_INFO_ID = 2,
    
    /** CrashReport.app_info.app_identifier */
    APIGEE_PLCRASH_PROTO_APP_INFO_APP_IDENTIFIER_ID = 1,
    
    /** CrashReport.app_info.app_version */
    APIGEE_PLCRASH_PROTO_APP_INFO_APP_VERSION_ID = 2,


    /** CrashReport.symbol.name */
    APIGEE_PLCRASH_PROTO_SYMBOL_NAME = 1,

    /** CrashReport.symbol.start_address */
    APIGEE_PLCRASH_PROTO_SYMBOL_START_ADDRESS = 2,
    
    /** CrashReport.symbol.end_address */
    APIGEE_PLCRASH_PROTO_SYMBOL_END_ADDRESS = 3,


    /** CrashReport.threads */
    APIGEE_PLCRASH_PROTO_THREADS_ID = 3,
    

    /** CrashReports.thread.thread_number */
    APIGEE_PLCRASH_PROTO_THREAD_THREAD_NUMBER_ID = 1,

    /** CrashReports.thread.frames */
    APIGEE_PLCRASH_PROTO_THREAD_FRAMES_ID = 2,

    /** CrashReport.thread.crashed */
    APIGEE_PLCRASH_PROTO_THREAD_CRASHED_ID = 3,


    /** CrashReport.thread.frame.pc */
    APIGEE_PLCRASH_PROTO_THREAD_FRAME_PC_ID = 3,
    
    /** CrashReport.thread.frame.symbol */
    APIGEE_PLCRASH_PROTO_THREAD_FRAME_SYMBOL_ID = 6,


    /** CrashReport.thread.registers */
    APIGEE_PLCRASH_PROTO_THREAD_REGISTERS_ID = 4,

    /** CrashReport.thread.register.name */
    APIGEE_PLCRASH_PROTO_THREAD_REGISTER_NAME_ID = 1,

    /** CrashReport.thread.register.name */
    APIGEE_PLCRASH_PROTO_THREAD_REGISTER_VALUE_ID = 2,


    /** CrashReport.images */
    APIGEE_PLCRASH_PROTO_BINARY_IMAGES_ID = 4,

    /** CrashReport.BinaryImage.base_address */
    APIGEE_PLCRASH_PROTO_BINARY_IMAGE_ADDR_ID = 1,

    /** CrashReport.BinaryImage.size */
    APIGEE_PLCRASH_PROTO_BINARY_IMAGE_SIZE_ID = 2,

    /** CrashReport.BinaryImage.name */
    APIGEE_PLCRASH_PROTO_BINARY_IMAGE_NAME_ID = 3,
    
    /** CrashReport.BinaryImage.uuid */
    APIGEE_PLCRASH_PROTO_BINARY_IMAGE_UUID_ID = 4,

    /** CrashReport.BinaryImage.code_type */
    APIGEE_PLCRASH_PROTO_BINARY_IMAGE_CODE_TYPE_ID = 5,

    
    /** CrashReport.exception */
    APIGEE_PLCRASH_PROTO_EXCEPTION_ID = 5,

    /** CrashReport.exception.name */
    APIGEE_PLCRASH_PROTO_EXCEPTION_NAME_ID = 1,
    
    /** CrashReport.exception.reason */
    APIGEE_PLCRASH_PROTO_EXCEPTION_REASON_ID = 2,
    
    /** CrashReports.exception.frames */
    APIGEE_PLCRASH_PROTO_EXCEPTION_FRAMES_ID = 3,


    /** CrashReport.signal */
    APIGEE_PLCRASH_PROTO_SIGNAL_ID = 6,

    /** CrashReport.signal.name */
    APIGEE_PLCRASH_PROTO_SIGNAL_NAME_ID = 1,

    /** CrashReport.signal.code */
    APIGEE_PLCRASH_PROTO_SIGNAL_CODE_ID = 2,
    
    /** CrashReport.signal.address */
    APIGEE_PLCRASH_PROTO_SIGNAL_ADDRESS_ID = 3,
    
    /** CrashReport.signal.mach_exception */
    APIGEE_PLCRASH_PROTO_SIGNAL_MACH_EXCEPTION_ID = 4,
    
    
    /** CrashReport.signal.mach_exception.type */
    APIGEE_PLCRASH_PROTO_SIGNAL_MACH_EXCEPTION_TYPE_ID = 1,
    
    /** CrashReport.signal.mach_exception.codes */
    APIGEE_PLCRASH_PROTO_SIGNAL_MACH_EXCEPTION_CODES_ID = 2,


    /** CrashReport.process_info */
    APIGEE_PLCRASH_PROTO_PROCESS_INFO_ID = 7,
    
    /** CrashReport.process_info.process_name */
    APIGEE_PLCRASH_PROTO_PROCESS_INFO_PROCESS_NAME_ID = 1,
    
    /** CrashReport.process_info.process_id */
    APIGEE_PLCRASH_PROTO_PROCESS_INFO_PROCESS_ID_ID = 2,
    
    /** CrashReport.process_info.process_path */
    APIGEE_PLCRASH_PROTO_PROCESS_INFO_PROCESS_PATH_ID = 3,
    
    /** CrashReport.process_info.parent_process_name */
    APIGEE_PLCRASH_PROTO_PROCESS_INFO_PARENT_PROCESS_NAME_ID = 4,
    
    /** CrashReport.process_info.parent_process_id */
    APIGEE_PLCRASH_PROTO_PROCESS_INFO_PARENT_PROCESS_ID_ID = 5,
    
    /** CrashReport.process_info.native */
    APIGEE_PLCRASH_PROTO_PROCESS_INFO_NATIVE_ID = 6,
    
    /** CrashReport.process_info.start_time */
    APIGEE_PLCRASH_PROTO_PROCESS_INFO_START_TIME_ID = 7,

    
    /** CrashReport.Processor.encoding */
    APIGEE_PLCRASH_PROTO_PROCESSOR_ENCODING_ID = 1,
    
    /** CrashReport.Processor.encoding */
    APIGEE_PLCRASH_PROTO_PROCESSOR_TYPE_ID = 2,
    
    /** CrashReport.Processor.encoding */
    APIGEE_PLCRASH_PROTO_PROCESSOR_SUBTYPE_ID = 3,


    /** CrashReport.machine_info */
    APIGEE_PLCRASH_PROTO_MACHINE_INFO_ID = 8,

    /** CrashReport.machine_info.model */
    APIGEE_PLCRASH_PROTO_MACHINE_INFO_MODEL_ID = 1,

    /** CrashReport.machine_info.processor */
    APIGEE_PLCRASH_PROTO_MACHINE_INFO_PROCESSOR_ID = 2,

    /** CrashReport.machine_info.processor_count */
    APIGEE_PLCRASH_PROTO_MACHINE_INFO_PROCESSOR_COUNT_ID = 3,

    /** CrashReport.machine_info.logical_processor_count */
    APIGEE_PLCRASH_PROTO_MACHINE_INFO_LOGICAL_PROCESSOR_COUNT_ID = 4,


    /** CrashReport.report_info */
    APIGEE_PLCRASH_PROTO_REPORT_INFO_ID = 9,
    
    /** CrashReport.report_info.crashed */
    APIGEE_PLCRASH_PROTO_REPORT_INFO_USER_REQUESTED_ID = 1,

    /** CrashReport.report_info.uuid */
    APIGEE_PLCRASH_PROTO_REPORT_INFO_UUID_ID = 2,
};

/**
 * Initialize a new crash log writer instance and issue a memory barrier upon completion. This fetches all necessary
 * environment information.
 *
 * @param writer Writer instance to be initialized.
 * @param app_identifier Unique per-application identifier. On Mac OS X, this is likely the CFBundleIdentifier.
 * @param app_version Application version string.
 * @param symbol_strategy The strategy to use for local symbolication.
 * @param user_requested If true, the written report will be marked as a 'generated' non-crash report, rather than as
 * a true crash report created upon an actual crash.
 *
 * @note If this function fails, plcrash_log_writer_free() should be called
 * to free any partially allocated data.
 *
 * @warning This function is not guaranteed to be async-safe, and must be called prior to enabling the crash handler.
 */
apigee_plcrash_error_t apigee_plcrash_log_writer_init (apigee_plcrash_log_writer_t *writer,
                                         NSString *app_identifier,
                                         NSString *app_version,
                                         apigee_plcrash_async_symbol_strategy_t symbol_strategy,
                                         BOOL user_requested)
{
    /* Default to 0 */
    memset(writer, 0, sizeof(*writer));

    /* Initialize configuration */
    writer->symbol_strategy = symbol_strategy;

    /* Default to false */
    writer->report_info.user_requested = user_requested;

    /* Generate a UUID for this incident; CFUUID is used in favor of NSUUID as to maintain compatibility
     * with (Mac OS X 10.7|iOS 5) and earlier. */
    {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuid);
        PLCF_ASSERT(sizeof(bytes) == sizeof(writer->report_info.uuid_bytes));
        memcpy(writer->report_info.uuid_bytes, &bytes, sizeof(writer->report_info.uuid_bytes));
        CFRelease(uuid);
    }

    /* Fetch the application information */
    {
        writer->application_info.app_identifier = strdup([app_identifier UTF8String]);
        writer->application_info.app_version = strdup([app_version UTF8String]);
    }
    
    /* Fetch the process information */
    {
        /* Current process */
        ApigeePLCrashProcessInfo *pinfo = [ApigeePLCrashProcessInfo currentProcessInfo];
        if (pinfo == nil) {
            /* Should only occur if the process is no longer valid */
            PLCF_DEBUG("Could not retreive process info for target");
            return APIGEE_PLCRASH_EINVAL;
        }

        {
            /* Retrieve PID */
            writer->process_info.process_id = pinfo.processID;

            /* Retrieve name and start time. */
            writer->process_info.process_name = strdup([pinfo.processName UTF8String]);
            writer->process_info.start_time = pinfo.startTime.tv_sec;

            /* Retrieve path */
            char *process_path = NULL;
            uint32_t process_path_len = 0;

            _NSGetExecutablePath(NULL, &process_path_len);
            if (process_path_len > 0) {
                process_path = malloc(process_path_len);
                _NSGetExecutablePath(process_path, &process_path_len);
                writer->process_info.process_path = process_path;
            }
        }

        /* Parent process */
        {
            /* Retrieve PID */
            writer->process_info.parent_process_id = pinfo.parentProcessID;

            /* Retrieve name */
            ApigeePLCrashProcessInfo *parentInfo = [[ApigeePLCrashProcessInfo alloc] initWithProcessID: pinfo.parentProcessID];
            if (parentInfo != nil) {
                writer->process_info.parent_process_name = strdup([parentInfo.processName UTF8String]);
            } else {
                PLCF_DEBUG("Could not retreive parent process name: %s", strerror(errno));
            }

        }
    }

    /* Fetch the machine information */
    {
        /* Model */
#if TARGET_OS_IPHONE
        /* On iOS, we want hw.machine (e.g. hw.machine = iPad2,1; hw.model = K93AP) */
        writer->machine_info.model = apigee_plcrash_sysctl_string("hw.machine");
#else
        /* On Mac OS X, we want hw.model (e.g. hw.machine = x86_64; hw.model = Macmini5,3) */
        writer->machine_info.model = apigee_plcrash_sysctl_string("hw.model");
#endif
        if (writer->machine_info.model == NULL) {
            PLCF_DEBUG("Could not retrive hw.model: %s", strerror(errno));
        }
        
        /* CPU */
        {
            int retval;

            /* Fetch the CPU types */
            if (apigee_plcrash_sysctl_int("hw.cputype", &retval)) {
                writer->machine_info.cpu_type = retval;
            } else {
                PLCF_DEBUG("Could not retrive hw.cputype: %s", strerror(errno));
            }
            
            if (apigee_plcrash_sysctl_int("hw.cpusubtype", &retval)) {
                writer->machine_info.cpu_subtype = retval;
            } else {
                PLCF_DEBUG("Could not retrive hw.cpusubtype: %s", strerror(errno));
            }

            /* Processor count */
            if (apigee_plcrash_sysctl_int("hw.physicalcpu_max", &retval)) {
                writer->machine_info.processor_count = retval;
            } else {
                PLCF_DEBUG("Could not retrive hw.physicalcpu_max: %s", strerror(errno));
            }

            if (apigee_plcrash_sysctl_int("hw.logicalcpu_max", &retval)) {
                writer->machine_info.logical_processor_count = retval;
            } else {
                PLCF_DEBUG("Could not retrive hw.logicalcpu_max: %s", strerror(errno));
            }
        }
        
        /*
         * Check if the process is emulated. This sysctl is defined in the Universal Binary Programming Guidelines,
         * Second Edition:
         *
         * http://developer.apple.com/legacy/mac/library/documentation/MacOSX/Conceptual/universal_binary/universal_binary.pdf
         */
        {
            int retval;

            if (apigee_plcrash_sysctl_int("sysctl.proc_native", &retval)) {
                if (retval == 0) {
                    writer->process_info.native = false;
                } else {
                    writer->process_info.native = true;
                }
            } else {
                /* If the sysctl is not available, the process can be assumed to be native. */
                writer->process_info.native = true;
            }
        }
    }

    /* Fetch the OS information */    
    writer->system_info.build = apigee_plcrash_sysctl_string("kern.osversion");
    if (writer->system_info.build == NULL) {
        PLCF_DEBUG("Could not retrive kern.osversion: %s", strerror(errno));
    }

#if TARGET_OS_IPHONE
    /* iPhone OS */
    writer->system_info.version = strdup([[[UIDevice currentDevice] systemVersion] UTF8String]);
#elif TARGET_OS_MAC
    /* Mac OS X */
    {
        SInt32 major, minor, bugfix;

        /* Fetch the major, minor, and bugfix versions.
         * Fetching the OS version should not fail. */
        if (Gestalt(gestaltSystemVersionMajor, &major) != noErr) {
            PLCF_DEBUG("Could not retreive system major version with Gestalt");
            return APIGEE_PLCRASH_EINTERNAL;
        }
        if (Gestalt(gestaltSystemVersionMinor, &minor) != noErr) {
            PLCF_DEBUG("Could not retreive system minor version with Gestalt");
            return APIGEE_PLCRASH_EINTERNAL;
        }
        if (Gestalt(gestaltSystemVersionBugFix, &bugfix) != noErr) {
            PLCF_DEBUG("Could not retreive system bugfix version with Gestalt");
            return APIGEE_PLCRASH_EINTERNAL;
        }

        /* Compose the string */
        asprintf(&writer->system_info.version, "%" PRId32 ".%" PRId32 ".%" PRId32, (int32_t)major, (int32_t)minor, (int32_t)bugfix);
    }
#else
#error Unsupported Platform
#endif

    /* Ensure that any signal handler has a consistent view of the above initialization. */
    OSMemoryBarrier();

    return APIGEE_PLCRASH_ESUCCESS;
}

/**
 * Set the uncaught exception for this writer. Once set, this exception will be used to
 * provide exception data for the crash log output.
 *
 * @warning This function is not async safe, and must be called outside of a signal handler.
 */
void apigee_plcrash_log_writer_set_exception (apigee_plcrash_log_writer_t *writer, NSException *exception) {
    assert(writer->uncaught_exception.has_exception == false);

    /* Save the exception data */
    writer->uncaught_exception.has_exception = true;
    writer->uncaught_exception.name = strdup([[exception name] UTF8String]);
    writer->uncaught_exception.reason = strdup([[exception reason] UTF8String]);

    /* Save the call stack, if available */
    NSArray *callStackArray = [exception callStackReturnAddresses];
    if (callStackArray != nil && [callStackArray count] > 0) {
        size_t count = [callStackArray count];
        writer->uncaught_exception.callstack_count = count;
        writer->uncaught_exception.callstack = malloc(sizeof(void *) * count);

        size_t i = 0;
        for (NSNumber *num in callStackArray) {
            assert(i < count);
            writer->uncaught_exception.callstack[i] = (void *)(uintptr_t)[num unsignedLongLongValue];
            i++;
        }
    }

    /* Ensure that any signal handler has a consistent view of the above initialization. */
    OSMemoryBarrier();
}

/**
 * Close the plcrash_writer_t output.
 *
 * @param writer Writer instance to be closed.
 */
apigee_plcrash_error_t apigee_plcrash_log_writer_close (apigee_plcrash_log_writer_t *writer) {
    return APIGEE_PLCRASH_ESUCCESS;
}

/**
 * Free any crash log writer resources.
 *
 * @warning This method is not async safe.
 */
void apigee_plcrash_log_writer_free (apigee_plcrash_log_writer_t *writer) {
    /* Free the app info */
    if (writer->application_info.app_identifier != NULL)
        free(writer->application_info.app_identifier);
    if (writer->application_info.app_version != NULL)
        free(writer->application_info.app_version);

    /* Free the process info */
    if (writer->process_info.process_name != NULL) 
        free(writer->process_info.process_name);
    if (writer->process_info.process_path != NULL) 
        free(writer->process_info.process_path);
    if (writer->process_info.parent_process_name != NULL) 
        free(writer->process_info.parent_process_name);
    
    /* Free the system info */
    if (writer->system_info.version != NULL)
        free(writer->system_info.version);
    
    if (writer->system_info.build != NULL)
        free(writer->system_info.build);
    
    /* Free the machine info */
    if (writer->machine_info.model != NULL)
        free(writer->machine_info.model);

    /* Free the exception data */
    if (writer->uncaught_exception.has_exception) {
        if (writer->uncaught_exception.name != NULL)
            free(writer->uncaught_exception.name);

        if (writer->uncaught_exception.reason != NULL)
            free(writer->uncaught_exception.reason);
        
        if (writer->uncaught_exception.callstack != NULL)
            free(writer->uncaught_exception.callstack);
    }
}

/**
 * @internal
 *
 * Write the system info message.
 *
 * @param file Output file
 * @param timestamp Timestamp to use (seconds since epoch). Must be same across calls, as varint encoding.
 */
static size_t apigee_plcrash_writer_write_system_info (apigee_plcrash_async_file_t *file, apigee_plcrash_log_writer_t *writer, int64_t timestamp) {
    size_t rv = 0;
    uint32_t enumval;

    /* OS */
    enumval = ApigeePLCrashReportHostOperatingSystem;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SYSTEM_INFO_OS_ID, APIGEE_PLPROTOBUF_C_TYPE_ENUM, &enumval);

    /* OS Version */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SYSTEM_INFO_OS_VERSION_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, writer->system_info.version);
    
    /* OS Build */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SYSTEM_INFO_OS_BUILD_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, writer->system_info.build);

    /* Machine type */
    enumval = ApigeePLCrashReportHostArchitecture;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SYSTEM_INFO_ARCHITECTURE_TYPE_ID, APIGEE_PLPROTOBUF_C_TYPE_ENUM, &enumval);

    /* Timestamp */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SYSTEM_INFO_TIMESTAMP_ID, APIGEE_PLPROTOBUF_C_TYPE_INT64, &timestamp);

    return rv;
}

/**
 * @internal
 *
 * Write the processor info message.
 *
 * @param file Output file
 * @param cpu_type The Mach CPU type.
 * @param cpu_subtype_t The Mach CPU subtype
 */
static size_t apigee_plcrash_writer_write_processor_info (apigee_plcrash_async_file_t *file, uint64_t cpu_type, uint64_t cpu_subtype) {
    size_t rv = 0;
    uint32_t enumval;
    
    /* Encoding */
    enumval = ApigeePLCrashReportProcessorTypeEncodingMach;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESSOR_ENCODING_ID, APIGEE_PLPROTOBUF_C_TYPE_ENUM, &enumval);

    /* Type */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESSOR_TYPE_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &cpu_type);

    /* Subtype */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESSOR_SUBTYPE_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &cpu_subtype);
    
    return rv;
}

/**
 * @internal
 *
 * Write the machine info message.
 *
 * @param file Output file
 */
static size_t apigee_plcrash_writer_write_machine_info (apigee_plcrash_async_file_t *file, apigee_plcrash_log_writer_t *writer) {
    size_t rv = 0;
    
    /* Model */
    if (writer->machine_info.model != NULL)
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_MACHINE_INFO_MODEL_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, writer->machine_info.model);

    /* Processor */
    {
        uint32_t size;

        /* Determine size */
        size = apigee_plcrash_writer_write_processor_info(NULL, writer->machine_info.cpu_type, writer->machine_info.cpu_subtype);

        /* Write message */
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_MACHINE_INFO_PROCESSOR_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        rv += apigee_plcrash_writer_write_processor_info(file, writer->machine_info.cpu_type, writer->machine_info.cpu_subtype);
    }

    /* Physical Processor Count */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_MACHINE_INFO_PROCESSOR_COUNT_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT32, &writer->machine_info.processor_count);
    
    /* Logical Processor Count */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_MACHINE_INFO_LOGICAL_PROCESSOR_COUNT_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT32, &writer->machine_info.logical_processor_count);
    
    return rv;
}

/**
 * @internal
 *
 * Write the app info message.
 *
 * @param file Output file
 * @param app_identifier Application identifier
 * @param app_version Application version
 */
static size_t apigee_plcrash_writer_write_app_info (apigee_plcrash_async_file_t *file, const char *app_identifier, const char *app_version) {
    size_t rv = 0;

    /* App identifier */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_APP_INFO_APP_IDENTIFIER_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, app_identifier);
    
    /* App version */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_APP_INFO_APP_VERSION_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, app_version);
    
    return rv;
}

/**
 * @internal
 *
 * Write the process info message.
 *
 * @param file Output file
 * @param process_name Process name
 * @param process_id Process ID
 * @param process_path Process path
 * @param parent_process_name Parent process name
 * @param parent_process_id Parent process ID
 * @param native If false, process is running under emulation.
 * @param start_time The start time of the process.
 */
static size_t apigee_plcrash_writer_write_process_info (apigee_plcrash_async_file_t *file, const char *process_name,
                                                 const pid_t process_id, const char *process_path, 
                                                 const char *parent_process_name, const pid_t parent_process_id,
                                                 bool native, time_t start_time)
{
    size_t rv = 0;
    uint64_t tval;

    /*
     * In the current crash reporter serialization format, pid values are serialized as unsigned 32-bit integers. This
     * conforms with the actual implementation of pid_t on both 32-bit and 64-bit Darwin systems. To conform with
     * SuSV3, however, the values should be encoded as signed integers; the actual width of the type being implementation
     * defined.
     *
     * To maintain compatibility with existing report readers the values remain encoded as unsigned 32-bit integers,
     * but should be updated to int64 values in future major revision of the data format.
     */
    uint32_t pidval;

    /* Process name */
    if (process_name != NULL)
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESS_INFO_PROCESS_NAME_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, process_name);

    /* Process ID */
    pidval = process_id;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESS_INFO_PROCESS_ID_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT32, &pidval);

    /* Process path */
    if (process_path != NULL)
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESS_INFO_PROCESS_PATH_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, process_path);
    
    /* Parent process name */
    if (parent_process_name != NULL)
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESS_INFO_PARENT_PROCESS_NAME_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, parent_process_name);
    

    /* Parent process ID */
    pidval = parent_process_id;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESS_INFO_PARENT_PROCESS_ID_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT32, &pidval);

    /* Native process. */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESS_INFO_NATIVE_ID, APIGEE_PLPROTOBUF_C_TYPE_BOOL, &native);
    
    /* Start time */
    tval = start_time;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESS_INFO_START_TIME_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &tval);

    return rv;
}

/**
 * @internal
 *
 * Write a thread backtrace register
 *
 * @param file Output file
 * @param cursor The cursor from which to acquire frame data.
 */
static size_t apigee_plcrash_writer_write_thread_register (apigee_plcrash_async_file_t *file, const char *regname, apigee_plcrash_greg_t regval) {
    uint64_t uint64val;
    size_t rv = 0;

    /* Write the name */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_THREAD_REGISTER_NAME_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, regname);

    /* Write the value */
    uint64val = regval;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_THREAD_REGISTER_VALUE_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &uint64val);
    
    return rv;
}

/**
 * @internal
 *
 * Write all thread backtrace register messages
 *
 * @param file Output file
 * @param task The task from which @a uap was derived. All memory accesses will be mapped from this task.
 * @param cursor The cursor from which to acquire frame registers.
 */
static size_t apigee_plcrash_writer_write_thread_registers (apigee_plcrash_async_file_t *file, task_t task, apigee_plframe_cursor_t *cursor) {
    apigee_plframe_error_t frame_err;
    uint32_t regCount = apigee_plframe_cursor_get_regcount(cursor);
    size_t rv = 0;
    
    /* Write out register messages */
    for (int i = 0; i < regCount; i++) {
        apigee_plcrash_greg_t regVal;
        const char *regname;
        uint32_t msgsize;

        /* Fetch the register value */
        if ((frame_err = apigee_plframe_cursor_get_reg(cursor, i, &regVal)) != APIGEE_PLFRAME_ESUCCESS) {
            // Should never happen
            PLCF_DEBUG("Could not fetch register %i value: %s", i, apigee_plframe_strerror(frame_err));
            regVal = 0;
        }

        /* Fetch the register name */
        regname = apigee_plframe_cursor_get_regname(cursor, i);

        /* Get the register message size */
        msgsize = apigee_plcrash_writer_write_thread_register(NULL, regname, regVal);
        
        /* Write the header and message */
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_THREAD_REGISTERS_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &msgsize);
        rv += apigee_plcrash_writer_write_thread_register(file, regname, regVal);
    }
    
    return rv;
}

/**
 * @internal
 *
 * Write a symbol
 *
 * @param file Output file
 * @param name The symbol name
 * @param start_address The symbol start address
 */
static size_t apigee_plcrash_writer_write_symbol (apigee_plcrash_async_file_t *file, const char *name, uint64_t start_address) {
    size_t rv = 0;
    
    /* name */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SYMBOL_NAME, APIGEE_PLPROTOBUF_C_TYPE_STRING, name);
    
    /* start_address */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SYMBOL_START_ADDRESS, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &start_address);
    
    return rv;
}

/**
 * @internal
 * Symbol lookup callback context
 */
struct apigee_pl_symbol_cb_ctx {
    /** File to use for writing out a symbol entry. May be NULL. */
    apigee_plcrash_async_file_t *file;

    /** Size of the symbol entry, to be written by the callback function upon writing an entry. */
    uint32_t msgsize;
};

/**
 * @internal
 *
 * pl_async_macho_found_symbol_cb callback implementation. Writes the result to the file available via @a ctx,
 * which must be a valid pl_symbol_cb_ctx structure.
 */
static void apigee_plcrash_writer_write_thread_frame_symbol_cb (pl_vm_address_t address, const char *name, void *ctx) {
    struct apigee_pl_symbol_cb_ctx *cb_ctx = ctx;
    cb_ctx->msgsize = apigee_plcrash_writer_write_symbol(cb_ctx->file, name, address);
}

/**
 * @internal
 *
 * Write a thread backtrace frame
 *
 * @param file Output file
 * @param pcval The frame PC value.
 */
static size_t apigee_plcrash_writer_write_thread_frame (apigee_plcrash_async_file_t *file, apigee_plcrash_log_writer_t *writer, uint64_t pcval, apigee_plcrash_async_image_list_t *image_list, apigee_plcrash_async_symbol_cache_t *findContext) {
    size_t rv = 0;

    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_THREAD_FRAME_PC_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &pcval);
    
    apigee_plcrash_async_image_list_set_reading(image_list, true);
    apigee_plcrash_async_image_t *image = apigee_plcrash_async_image_containing_address(image_list, (pl_vm_address_t) pcval);
    
    if (image != NULL && writer->symbol_strategy != APIGEE_PLCRASH_ASYNC_SYMBOL_STRATEGY_NONE) {
        struct apigee_pl_symbol_cb_ctx ctx;
        apigee_plcrash_error_t ret;
        
        /* Get the symbol message size. If the symbol can not be found, our callback will not be called. If the symbol is found,
         * our callback is called and PLCRASH_ESUCCESS is returned. */
        ctx.file = NULL;
        ctx.msgsize = 0x0;
        ret = apigee_plcrash_async_find_symbol(&image->macho_image, writer->symbol_strategy, findContext, (pl_vm_address_t) pcval, apigee_plcrash_writer_write_thread_frame_symbol_cb, &ctx);
        if (ret == APIGEE_PLCRASH_ESUCCESS) {
            /* Write the header and message */
            rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_THREAD_FRAME_SYMBOL_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &ctx.msgsize);

            ctx.file = file;
            ret = apigee_plcrash_async_find_symbol(&image->macho_image, writer->symbol_strategy, findContext, (pl_vm_address_t) pcval, apigee_plcrash_writer_write_thread_frame_symbol_cb, &ctx);
            if (ret == APIGEE_PLCRASH_ESUCCESS) {
                rv += ctx.msgsize;
            } else {
                /* This should not happen, but it would be very confusing if it did and nothing was logged. */
                PLCF_DEBUG("Fetching the symbol unexpectedly failed during the second call");
            }
        }
    }

    apigee_plcrash_async_image_list_set_reading(image_list, false);


    return rv;
}

/**
 * @internal
 *
 * Write a thread message
 *
 * @param file Output file
 * @param task The task in which @a thread is executing.
 * @param thread Thread for which we'll output data.
 * @param thread_number The thread's index number.
 * @param thread_ctx Thread state to use for stack walking. If NULL, the thread state will be fetched from @a thread. If
 * @a thread is the currently executing thread, <em>must</em> be non-NULL.
 * @param image_list The Mach-O image list.
 * @param findContext Symbol lookup cache.
 * @param crashed If true, mark this as a crashed thread.
 */
static size_t apigee_plcrash_writer_write_thread (apigee_plcrash_async_file_t *file,
                                           apigee_plcrash_log_writer_t *writer,
                                           task_t task,
                                           thread_t thread,
                                           uint32_t thread_number,
                                           apigee_plcrash_async_thread_state_t *thread_ctx,
                                           apigee_plcrash_async_image_list_t *image_list,
                                           apigee_plcrash_async_symbol_cache_t *findContext,
                                           bool crashed)
{
    size_t rv = 0;
    apigee_plframe_cursor_t cursor;
    apigee_plframe_error_t ferr;

    /* A context must be supplied when walking the current thread */
    PLCF_ASSERT(task != mach_task_self() || thread_ctx != NULL || thread != apigee_pl_mach_thread_self());

    /* Write the required elements first; fatal errors may occur below, in which case we need to have
     * written out required elements before returning. */
    {
        /* Write the thread ID */
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_THREAD_THREAD_NUMBER_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT32, &thread_number);

        /* Note crashed status */
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_THREAD_CRASHED_ID, APIGEE_PLPROTOBUF_C_TYPE_BOOL, &crashed);
    }


    /* Write out the stack frames. */
    {
        /* Set up the frame cursor. */
        {            
            /* Use the provided context if available, otherwise initialize a new thread context
             * from the target thread's state. */
            apigee_plcrash_async_thread_state_t cursor_thr_state;
            if (thread_ctx) {
                cursor_thr_state = *thread_ctx;
            } else {
                apigee_plcrash_async_thread_state_mach_thread_init(&cursor_thr_state, thread);
            }

            /* Initialize the cursor */
            ferr = apigee_plframe_cursor_init(&cursor, task, &cursor_thr_state, image_list);
            if (ferr != APIGEE_PLFRAME_ESUCCESS) {
                PLCF_DEBUG("An error occured initializing the frame cursor: %s", apigee_plframe_strerror(ferr));
                return rv;
            }
        }

        /* Walk the stack, limiting the total number of frames that are output. */
        uint32_t frame_count = 0;
        while ((ferr = apigee_plframe_cursor_next(&cursor)) == APIGEE_PLFRAME_ESUCCESS && frame_count < MAX_THREAD_FRAMES) {
            uint32_t frame_size;
            
            /* On the first frame, dump registers for the crashed thread */
            if (frame_count == 0 && crashed) {
                rv += apigee_plcrash_writer_write_thread_registers(file, task, &cursor);
            }

            /* Fetch the PC value */
            apigee_plcrash_greg_t pc = 0;
            if ((ferr = apigee_plframe_cursor_get_reg(&cursor, APIGEE_PLCRASH_REG_IP, &pc)) != APIGEE_PLFRAME_ESUCCESS) {
                PLCF_DEBUG("Could not retrieve frame PC register: %s", apigee_plframe_strerror(ferr));
                break;
            }

            /* Determine the size */
            frame_size = apigee_plcrash_writer_write_thread_frame(NULL, writer, pc, image_list, findContext);
            
            rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_THREAD_FRAMES_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &frame_size);
            rv += apigee_plcrash_writer_write_thread_frame(file, writer, pc, image_list, findContext);
            frame_count++;
        }

        /* Did we reach the end successfully? */
        if (ferr != APIGEE_PLFRAME_ENOFRAME) {
            /* This is non-fatal, and in some circumstances -could- be caused by reaching the end of the stack if the
             * final frame pointer is not NULL. */
            PLCF_DEBUG("Terminated stack walking early: %s", apigee_plframe_strerror(ferr));
        }
    }

    apigee_plframe_cursor_free(&cursor);
    return rv;
}


/**
 * @internal
 *
 * Write a binary image frame
 *
 * @param file Output file
 * @param name binary image path (or name).
 * @param image_base Mach-O image base.
 */
static size_t apigee_plcrash_writer_write_binary_image (apigee_plcrash_async_file_t *file, apigee_plcrash_async_macho_t *image) {
    size_t rv = 0;

    /* Fetch the CPU types. Note that the wire format represents these as 64-bit unsigned integers.
     * We explicitly cast to an equivalently sized unsigned type to prevent improper sign extension. */
    uint64_t cpu_type = (uint32_t) image->byteorder->swap32(image->header.cputype);
    uint64_t cpu_subtype = (uint32_t) image->byteorder->swap32(image->header.cpusubtype);

    /* Text segment size */
    uint64_t mach_size = image->text_size;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_BINARY_IMAGE_SIZE_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &mach_size);
    
    /* Base address */
    {
        uintptr_t base_addr;
        uint64_t u64;

        base_addr = (uintptr_t) image->header_addr;
        u64 = base_addr;
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_BINARY_IMAGE_ADDR_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &u64);
    }

    /* Name */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_BINARY_IMAGE_NAME_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, image->name);

    /* UUID */
    struct uuid_command *uuid;
    uuid = apigee_plcrash_async_macho_find_command(image, LC_UUID);
    if (uuid != NULL) {
        ApigeePLProtobufCBinaryData binary;
    
        /* Write the 128-bit UUID */
        binary.len = sizeof(uuid->uuid);
        binary.data = uuid->uuid;
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_BINARY_IMAGE_UUID_ID, APIGEE_PLPROTOBUF_C_TYPE_BYTES, &binary);
    }
    
    /* Get the processor message size */
    uint32_t msgsize = apigee_plcrash_writer_write_processor_info(NULL, cpu_type, cpu_subtype);

    /* Write the header and message */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_BINARY_IMAGE_CODE_TYPE_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &msgsize);
    rv += apigee_plcrash_writer_write_processor_info(file, cpu_type, cpu_subtype);

    return rv;
}


/**
 * @internal
 *
 * Write the crash Exception message
 *
 * @param file Output file
 * @param writer Writer containing exception data
 */
static size_t apigee_plcrash_writer_write_exception (apigee_plcrash_async_file_t *file, apigee_plcrash_log_writer_t *writer, apigee_plcrash_async_image_list_t *image_list, apigee_plcrash_async_symbol_cache_t *findContext) {
    size_t rv = 0;

    /* Write the name and reason */
    assert(writer->uncaught_exception.has_exception);
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_EXCEPTION_NAME_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, writer->uncaught_exception.name);
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_EXCEPTION_REASON_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, writer->uncaught_exception.reason);
    
    /* Write the stack frames, if any */
    uint32_t frame_count = 0;
    for (size_t i = 0; i < writer->uncaught_exception.callstack_count && frame_count < MAX_THREAD_FRAMES; i++) {
        uint64_t pc = (uint64_t)(uintptr_t) writer->uncaught_exception.callstack[i];
        
        /* Determine the size */
        uint32_t frame_size = apigee_plcrash_writer_write_thread_frame(NULL, writer, pc, image_list, findContext);
        
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_EXCEPTION_FRAMES_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &frame_size);
        rv += apigee_plcrash_writer_write_thread_frame(file, writer, pc, image_list, findContext);
        frame_count++;
    }

    return rv;
}

/**
 * @internal
 *
 * Write the crash signal's mach exception info.
 *
 * @param file Output file
 * @param siginfo The signal information
 */
static size_t apigee_plcrash_writer_write_mach_signal (apigee_plcrash_async_file_t *file, apigee_plcrash_log_mach_signal_info_t *siginfo) {
    size_t rv = 0;

    /* Type */
    uint64_t type = siginfo->type;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SIGNAL_MACH_EXCEPTION_TYPE_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &type);
    
    /* Code(s) */
    for (mach_msg_type_number_t i = 0; i < siginfo->code_count; i++) {
        uint64_t code = siginfo->code[i];
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SIGNAL_MACH_EXCEPTION_CODES_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &code);
    }

    return rv;
}

/**
 * @internal
 *
 * Write the crash signal message
 *
 * @param file Output file
 * @param siginfo The signal information
 */
static size_t apigee_plcrash_writer_write_signal (apigee_plcrash_async_file_t *file, apigee_plcrash_log_signal_info_t *siginfo) {
    size_t rv = 0;
    
    /* BSD signal info is always required in the current report format; this restriction will be lifted
     * once we switch to the 2.0 format. */
    PLCF_ASSERT(siginfo->bsd_info != NULL);
    
    /* Fetch the signal name */
    char name_buf[10];
    const char *name;
    if ((name = apigee_plcrash_async_signal_signame(siginfo->bsd_info->signo)) == NULL) {
        PLCF_DEBUG("Warning -- unhandled signal number (signo=%d). This is a bug.", siginfo->bsd_info->signo);
        snprintf(name_buf, sizeof(name_buf), "#%d", siginfo->bsd_info->signo);
        name = name_buf;
    }

    /* Fetch the signal code string */
    char code_buf[10];
    const char *code;
    if ((code = apigee_plcrash_async_signal_sigcode(siginfo->bsd_info->signo, siginfo->bsd_info->code)) == NULL) {
        PLCF_DEBUG("Warning -- unhandled signal sicode (signo=%d, code=%d). This is a bug.", siginfo->bsd_info->signo, siginfo->bsd_info->code);
        snprintf(code_buf, sizeof(code_buf), "#%d", siginfo->bsd_info->code);
        code = code_buf;
    }
    
    /* Address value */
    uint64_t addr = (uintptr_t) siginfo->bsd_info->address;

    /* Write it out */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SIGNAL_NAME_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, name);
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SIGNAL_CODE_ID, APIGEE_PLPROTOBUF_C_TYPE_STRING, code);
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SIGNAL_ADDRESS_ID, APIGEE_PLPROTOBUF_C_TYPE_UINT64, &addr);
    
    /* Mach exception info */
    if (siginfo->mach_info != NULL) {
        uint32_t size;
        
        /* Determine size */
        size = apigee_plcrash_writer_write_mach_signal(NULL, siginfo->mach_info);
        
        /* Write message */
        rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SIGNAL_MACH_EXCEPTION_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        rv += apigee_plcrash_writer_write_mach_signal(file, siginfo->mach_info);
    }

    return rv;
}

/**
 * @internal
 *
 * Write the report info message
 *
 * @param file Output file
 * @param writer Writer containing report data
 */
static size_t apigee_plcrash_writer_write_report_info (apigee_plcrash_async_file_t *file, apigee_plcrash_log_writer_t *writer) {
    size_t rv = 0;

    /* Note crashed status */
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_REPORT_INFO_USER_REQUESTED_ID, APIGEE_PLPROTOBUF_C_TYPE_BOOL, &writer->report_info.user_requested);
    
    /* Write the 128-bit UUID */
    ApigeePLProtobufCBinaryData uuid_bin;
    
    uuid_bin.len = sizeof(writer->report_info.uuid_bytes);
    uuid_bin.data = &writer->report_info.uuid_bytes;
    rv += apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_REPORT_INFO_UUID_ID, APIGEE_PLPROTOBUF_C_TYPE_BYTES, &uuid_bin);

    return rv;
}

/**
 * Write the crash report. All other running threads are suspended while the crash report is generated.
 *
 * @param writer The writer context.
 * @param crashed_thread The crashed thread. 
 * @param image_list The current list of loaded binary images.
 * @param file The output file.
 * @param siginfo Signal information.
 * @param current_state If non-NULL, the given thread state will be used when walking the current thread. The state must remain
 * valid until this function returns. Generally, this state will be generated by a signal handler, or via a
 * context-generating trampoline such as plcrash_log_writer_write_curthread(). If NULL, a thread dump for the current
 * thread will not be written. If @a crashed_thread is the current thread (as returned by mach_thread_self()), this
 * value <em>must</em> be provided.
 */
apigee_plcrash_error_t apigee_plcrash_log_writer_write (apigee_plcrash_log_writer_t *writer,
                                          thread_t crashed_thread,
                                          apigee_plcrash_async_image_list_t *image_list,
                                          apigee_plcrash_async_file_t *file,
                                          apigee_plcrash_log_signal_info_t *siginfo,
                                          apigee_plcrash_async_thread_state_t *current_state)
{
    thread_act_array_t threads;
    mach_msg_type_number_t thread_count;

    /* A context must be supplied if the current thread is marked as the crashed thread; otherwise,
     * the thread's stack can not be safely walked. */
    PLCF_ASSERT(apigee_pl_mach_thread_self() != crashed_thread || current_state != NULL);

    /* Get a list of all threads */
    if (task_threads(mach_task_self(), &threads, &thread_count) != KERN_SUCCESS) {
        PLCF_DEBUG("Fetching thread list failed");
        thread_count = 0;
    }
    
    /* Suspend all but the current thread. */
    for (mach_msg_type_number_t i = 0; i < thread_count; i++) {
        if (threads[i] != apigee_pl_mach_thread_self())
            thread_suspend(threads[i]);
    }

    /* Set up a symbol-finding context. */
    apigee_plcrash_async_symbol_cache_t findContext;
    apigee_plcrash_error_t err = apigee_plcrash_async_symbol_cache_init(&findContext);
    /* Abort if it failed, although that should never actually happen, ever. */
    if (err != APIGEE_PLCRASH_ESUCCESS)
        return err;

    /* Write the file header */
    {
        uint8_t version = PLCRASH_REPORT_FILE_VERSION;

        /* Write the magic string (with no trailing NULL) and the version number */
        apigee_plcrash_async_file_write(file, PLCRASH_REPORT_FILE_MAGIC, strlen(PLCRASH_REPORT_FILE_MAGIC));
        apigee_plcrash_async_file_write(file, &version, sizeof(version));
    }
    
    
    /* Report Info */
    {
        uint32_t size;
        
        /* Determine size */
        size = apigee_plcrash_writer_write_report_info(NULL, writer);
        
        /* Write message */
        apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_REPORT_INFO_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        apigee_plcrash_writer_write_report_info(file, writer);
    }

    /* System Info */
    {
        time_t timestamp;
        uint32_t size;

        /* Must stay the same across both calls, so get the timestamp here */
        if (time(&timestamp) == (time_t)-1) {
            PLCF_DEBUG("Failed to fetch timestamp: %s", strerror(errno));
            timestamp = 0;
        }

        /* Determine size */
        size = apigee_plcrash_writer_write_system_info(NULL, writer, timestamp);
        
        /* Write message */
        apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SYSTEM_INFO_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        apigee_plcrash_writer_write_system_info(file, writer, timestamp);
    }
    
    /* Machine Info */
    {
        uint32_t size;

        /* Determine size */
        size = apigee_plcrash_writer_write_machine_info(NULL, writer);

        /* Write message */
        apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_MACHINE_INFO_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        apigee_plcrash_writer_write_machine_info(file, writer);
    }

    /* App info */
    {
        uint32_t size;

        /* Determine size */
        size = apigee_plcrash_writer_write_app_info(NULL, writer->application_info.app_identifier, writer->application_info.app_version);
        
        /* Write message */
        apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_APP_INFO_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        apigee_plcrash_writer_write_app_info(file, writer->application_info.app_identifier, writer->application_info.app_version);
    }
    
    /* Process info */
    {
        uint32_t size;
        
        /* Determine size */
        size = apigee_plcrash_writer_write_process_info(NULL, writer->process_info.process_name, writer->process_info.process_id,
                                                 writer->process_info.process_path, writer->process_info.parent_process_name,
                                                 writer->process_info.parent_process_id, writer->process_info.native,
                                                 writer->process_info.start_time);
        
        /* Write message */
        apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_PROCESS_INFO_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        apigee_plcrash_writer_write_process_info(file, writer->process_info.process_name, writer->process_info.process_id,
                                          writer->process_info.process_path, writer->process_info.parent_process_name, 
                                          writer->process_info.parent_process_id, writer->process_info.native,
                                          writer->process_info.start_time);
    }
    
    /* Threads */
    uint32_t thread_number = 0;
    for (mach_msg_type_number_t i = 0; i < thread_count; i++) {
        thread_t thread = threads[i];
        apigee_plcrash_async_thread_state_t *thr_ctx = NULL;
        bool crashed = false;
        uint32_t size;

        /* If executing on the target thread, we need to a valid context to walk */
        if (apigee_pl_mach_thread_self() == thread) {
            /* Can't log a report for the current thread without a valid context. */
            if (current_state == NULL)
                continue;
        
            thr_ctx = current_state;
        }
        
        /* Check if this is the crashed thread */
        if (crashed_thread == thread) {
            crashed = true;
        }

        /* Determine the size */
        size = apigee_plcrash_writer_write_thread(NULL, writer, mach_task_self(), thread, thread_number, thr_ctx, image_list, &findContext, crashed);

        /* Write message */
        apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_THREADS_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        apigee_plcrash_writer_write_thread(file, writer, mach_task_self(), thread, thread_number, thr_ctx, image_list, &findContext, crashed);

        thread_number++;
    }

    /* Binary Images */
    apigee_plcrash_async_image_list_set_reading(image_list, true);

    apigee_plcrash_async_image_t *image = NULL;
    while ((image = apigee_plcrash_async_image_list_next(image_list, image)) != NULL) {
        uint32_t size;

        /* Calculate the message size */
        size = apigee_plcrash_writer_write_binary_image(NULL, &image->macho_image);
        apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_BINARY_IMAGES_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        apigee_plcrash_writer_write_binary_image(file, &image->macho_image);
    }

    apigee_plcrash_async_image_list_set_reading(image_list, false);

    /* Exception */
    if (writer->uncaught_exception.has_exception) {
        uint32_t size;

        /* Calculate the message size */
        size = apigee_plcrash_writer_write_exception(NULL, writer, image_list, &findContext);
        apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_EXCEPTION_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        apigee_plcrash_writer_write_exception(file, writer, image_list, &findContext);
    }
    
    /* Signal */
    {
        uint32_t size;
        
        /* Calculate the message size */
        size = apigee_plcrash_writer_write_signal(NULL, siginfo);
        apigee_plcrash_writer_pack(file, APIGEE_PLCRASH_PROTO_SIGNAL_ID, APIGEE_PLPROTOBUF_C_TYPE_MESSAGE, &size);
        apigee_plcrash_writer_write_signal(file, siginfo);
    }
    
    apigee_plcrash_async_symbol_cache_free(&findContext);
    
    /* Clean up the thread array */
    for (mach_msg_type_number_t i = 0; i < thread_count; i++) {
        if (threads[i] != apigee_pl_mach_thread_self())
            thread_resume(threads[i]);

        mach_port_deallocate(mach_task_self(), threads[i]);
    }

    vm_deallocate(mach_task_self(), (vm_address_t)threads, sizeof(thread_t) * thread_count);
    
    return APIGEE_PLCRASH_ESUCCESS;
}


/**
 * @} plcrash_log_writer
 */
