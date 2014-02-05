/*
 * Copyright 2008, Dave Benson.
 * Copyright 2008 - 2009 Plausible Labs Cooperative, Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with
 * the License. You may obtain a copy of the License
 * at http://www.apache.org/licenses/LICENSE-2.0 Unless
 * required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#ifndef PLCRASH_LOG_WRITER_ENCODING_H
#define PLCRASH_LOG_WRITER_ENCODING_H

#ifdef __cplusplus
extern "C" {
#endif

#import "ApigeePLCrashAsync.h"

typedef enum {
        APIGEE_PLPROTOBUF_C_TYPE_INT32,
        APIGEE_PLPROTOBUF_C_TYPE_SINT32,
        APIGEE_PLPROTOBUF_C_TYPE_SFIXED32,
        APIGEE_PLPROTOBUF_C_TYPE_INT64,
        APIGEE_PLPROTOBUF_C_TYPE_SINT64,
        APIGEE_PLPROTOBUF_C_TYPE_SFIXED64,
        APIGEE_PLPROTOBUF_C_TYPE_UINT32,
        APIGEE_PLPROTOBUF_C_TYPE_FIXED32,
        APIGEE_PLPROTOBUF_C_TYPE_UINT64,
        APIGEE_PLPROTOBUF_C_TYPE_FIXED64,
        APIGEE_PLPROTOBUF_C_TYPE_FLOAT,
        APIGEE_PLPROTOBUF_C_TYPE_DOUBLE,
        APIGEE_PLPROTOBUF_C_TYPE_BOOL,
        APIGEE_PLPROTOBUF_C_TYPE_ENUM,
        APIGEE_PLPROTOBUF_C_TYPE_STRING,
        APIGEE_PLPROTOBUF_C_TYPE_BYTES,
        //APIGEE_PLPROTOBUF_C_TYPE_GROUP,          // NOT SUPPORTED
        APIGEE_PLPROTOBUF_C_TYPE_MESSAGE,
} ApigeePLProtobufCType;

typedef struct ApigeePLProtobufCBinaryData {
    size_t len;
    void *data;
} ApigeePLProtobufCBinaryData;

size_t apigee_plcrash_writer_pack (apigee_plcrash_async_file_t *file, uint32_t field_id, ApigeePLProtobufCType field_type, const void *value);
    
#ifdef __cplusplus
}
#endif

#endif /* PLCRASH_LOG_WRITER_ENCODING_H */
