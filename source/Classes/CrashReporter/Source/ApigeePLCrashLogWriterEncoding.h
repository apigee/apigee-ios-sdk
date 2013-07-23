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

#import "ApigeePLCrashAsync.h"

typedef enum {
        Apigee_PLPROTOBUF_C_TYPE_INT32,
        Apigee_PLPROTOBUF_C_TYPE_SINT32,
        Apigee_PLPROTOBUF_C_TYPE_SFIXED32,
        Apigee_PLPROTOBUF_C_TYPE_INT64,
        Apigee_PLPROTOBUF_C_TYPE_SINT64,
        Apigee_PLPROTOBUF_C_TYPE_SFIXED64,
        Apigee_PLPROTOBUF_C_TYPE_UINT32,
        Apigee_PLPROTOBUF_C_TYPE_FIXED32,
        Apigee_PLPROTOBUF_C_TYPE_UINT64,
        Apigee_PLPROTOBUF_C_TYPE_FIXED64,
        Apigee_PLPROTOBUF_C_TYPE_FLOAT,
        Apigee_PLPROTOBUF_C_TYPE_DOUBLE,
        Apigee_PLPROTOBUF_C_TYPE_BOOL,
        Apigee_PLPROTOBUF_C_TYPE_ENUM,
        Apigee_PLPROTOBUF_C_TYPE_STRING,
        Apigee_PLPROTOBUF_C_TYPE_BYTES,
        //PLPROTOBUF_C_TYPE_GROUP,          // NOT SUPPORTED
        Apigee_PLPROTOBUF_C_TYPE_MESSAGE,
} Apigee_PLProtobufCType;

typedef struct Apigee_PLProtobufCBinaryData {
    size_t len;
    void *data;
} Apigee_PLProtobufCBinaryData;

size_t Apigee_plcrash_writer_pack (Apigee_plcrash_async_file_t *file, uint32_t field_id, Apigee_PLProtobufCType field_type, const void *value);
