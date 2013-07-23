/* --- protobuf-c.h: public protobuf c runtime api --- */

/*
 * Copyright 2008, Dave Benson.
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

#ifndef __Apigee_PROTOBUF_C_RUNTIME_H_
#define __Apigee_PROTOBUF_C_RUNTIME_H_

#include <inttypes.h>
#include <stddef.h>
#include <assert.h>

#ifdef __cplusplus
# define Apigee_PROTOBUF_C_BEGIN_DECLS    extern "C" {
# define Apigee_PROTOBUF_C_END_DECLS      }
#else
# define Apigee_PROTOBUF_C_BEGIN_DECLS
# define Apigee_PROTOBUF_C_END_DECLS
#endif

Apigee_PROTOBUF_C_BEGIN_DECLS

typedef enum
{
  Apigee_PROTOBUF_C_LABEL_REQUIRED,
  Apigee_PROTOBUF_C_LABEL_OPTIONAL,
  Apigee_PROTOBUF_C_LABEL_REPEATED
} Apigee_ProtobufCLabel;

typedef enum
{
  Apigee_PROTOBUF_C_TYPE_INT32,
  Apigee_PROTOBUF_C_TYPE_SINT32,
  Apigee_PROTOBUF_C_TYPE_SFIXED32,
  Apigee_PROTOBUF_C_TYPE_INT64,
  Apigee_PROTOBUF_C_TYPE_SINT64,
  Apigee_PROTOBUF_C_TYPE_SFIXED64,
  Apigee_PROTOBUF_C_TYPE_UINT32,
  Apigee_PROTOBUF_C_TYPE_FIXED32,
  Apigee_PROTOBUF_C_TYPE_UINT64,
  Apigee_PROTOBUF_C_TYPE_FIXED64,
  Apigee_PROTOBUF_C_TYPE_FLOAT,
  Apigee_PROTOBUF_C_TYPE_DOUBLE,
  Apigee_PROTOBUF_C_TYPE_BOOL,
  Apigee_PROTOBUF_C_TYPE_ENUM,
  Apigee_PROTOBUF_C_TYPE_STRING,
  Apigee_PROTOBUF_C_TYPE_BYTES,
  //Apigee_PROTOBUF_C_TYPE_GROUP,          // NOT SUPPORTED
  Apigee_PROTOBUF_C_TYPE_MESSAGE,
} Apigee_ProtobufCType;

typedef int Apigee_protobuf_c_boolean;
#define Apigee_PROTOBUF_C_OFFSETOF(struct, member) offsetof(struct, member)

#define Apigee_PROTOBUF_C_ASSERT(condition) assert(condition)
#define Apigee_PROTOBUF_C_ASSERT_NOT_REACHED() assert(0)

typedef struct Apigee__ProtobufCBinaryData Apigee_ProtobufCBinaryData;
struct Apigee__ProtobufCBinaryData
{
  size_t len;
  uint8_t *data;
};

typedef struct Apigee__ProtobufCIntRange Apigee_ProtobufCIntRange; /* private */

/* --- memory management --- */
typedef struct Apigee__ProtobufCAllocator Apigee_ProtobufCAllocator;
struct Apigee__ProtobufCAllocator
{
  void *(*alloc)(void *allocator_data, size_t size);
  void (*free)(void *allocator_data, void *pointer);
  void *(*tmp_alloc)(void *allocator_data, size_t size);
  unsigned max_alloca;
  void *allocator_data;
};
extern Apigee_ProtobufCAllocator Apigee_protobuf_c_default_allocator; /* settable */
extern Apigee_ProtobufCAllocator Apigee_protobuf_c_system_allocator;  /* use malloc, free etc */

extern void (*Apigee_protobuf_c_out_of_memory) (void);

/* --- append-only data buffer --- */
typedef struct Apigee__ProtobufCBuffer Apigee_ProtobufCBuffer;
struct Apigee__ProtobufCBuffer
{
  void (*append)(Apigee_ProtobufCBuffer     *buffer,
                 size_t               len,
                 const uint8_t       *data);
};
/* --- enums --- */
typedef struct Apigee__ProtobufCEnumValue Apigee_ProtobufCEnumValue;
typedef struct Apigee__ProtobufCEnumValueIndex Apigee_ProtobufCEnumValueIndex;
typedef struct Apigee__ProtobufCEnumDescriptor Apigee_ProtobufCEnumDescriptor;

struct Apigee__ProtobufCEnumValue
{
  const char *name;
  const char *c_name;
  int value;
};

struct Apigee__ProtobufCEnumDescriptor
{
  uint32_t magic;

  const char *name;
  const char *short_name;
  const char *c_name;
  const char *package_name;

  /* sorted by value */
  unsigned n_values;
  const Apigee_ProtobufCEnumValue *values;

  /* sorted by name */
  unsigned n_value_names;
  const Apigee_ProtobufCEnumValueIndex *values_by_name;

  /* value-ranges, for faster lookups by number */
  unsigned n_value_ranges;
  const Apigee_ProtobufCIntRange *value_ranges;

  void *reserved1;
  void *reserved2;
  void *reserved3;
  void *reserved4;
};

/* --- messages --- */
typedef struct Apigee__ProtobufCMessageDescriptor Apigee_ProtobufCMessageDescriptor;
typedef struct Apigee__ProtobufCFieldDescriptor Apigee_ProtobufCFieldDescriptor;
struct Apigee__ProtobufCFieldDescriptor
{
  const char *name;
  uint32_t id;
  Apigee_ProtobufCLabel label;
  Apigee_ProtobufCType type;
  unsigned quantifier_offset;
  unsigned offset;
  const void *descriptor;   /* for MESSAGE and ENUM types */
  const void *default_value;   /* or NULL if no default-value */

  void *reserved1;
  void *reserved2;
};
struct Apigee__ProtobufCMessageDescriptor
{
  uint32_t magic;

  const char *name;
  const char *short_name;
  const char *c_name;
  const char *package_name;

  size_t sizeof_message;

  /* sorted by field-id */
  unsigned n_fields;
  const Apigee_ProtobufCFieldDescriptor *fields;
  const unsigned *fields_sorted_by_name;

  /* ranges, optimization for looking up fields */
  unsigned n_field_ranges;
  const Apigee_ProtobufCIntRange *field_ranges;

  void *reserved1;
  void *reserved2;
  void *reserved3;
  void *reserved4;
};


typedef struct Apigee__ProtobufCMessage Apigee_ProtobufCMessage;
typedef struct Apigee__ProtobufCMessageUnknownField Apigee_ProtobufCMessageUnknownField;
struct Apigee__ProtobufCMessage
{
  const Apigee_ProtobufCMessageDescriptor *descriptor;
  unsigned n_unknown_fields;
  Apigee_ProtobufCMessageUnknownField *unknown_fields;
};
#define Apigee_PROTOBUF_C_MESSAGE_INIT(descriptor) { descriptor, 0, NULL }

size_t    Apigee_protobuf_c_message_get_packed_size(const Apigee_ProtobufCMessage *message);
size_t    Apigee_protobuf_c_message_pack           (const Apigee_ProtobufCMessage *message,
                                             uint8_t                *out);
size_t    Apigee_protobuf_c_message_pack_to_buffer (const Apigee_ProtobufCMessage *message,
                                             Apigee_ProtobufCBuffer  *buffer);

Apigee_ProtobufCMessage *
          Apigee_protobuf_c_message_unpack         (const Apigee_ProtobufCMessageDescriptor *,
                                             Apigee_ProtobufCAllocator  *allocator,
                                             size_t               len,
                                             const uint8_t       *data);
void      Apigee_protobuf_c_message_free_unpacked  (Apigee_ProtobufCMessage    *message,
                                             Apigee_ProtobufCAllocator  *allocator);

/* WARNING: 'to_init' must be a block of memory 
   of size description->sizeof_message. */
size_t    Apigee_protobuf_c_message_init           (const Apigee_ProtobufCMessageDescriptor *,
                                             Apigee_ProtobufCMessage       *to_init);

/* --- services --- */
typedef struct Apigee__ProtobufCMethodDescriptor Apigee_ProtobufCMethodDescriptor;
typedef struct Apigee__ProtobufCServiceDescriptor Apigee_ProtobufCServiceDescriptor;

struct Apigee__ProtobufCMethodDescriptor
{
  const char *name;
  const Apigee_ProtobufCMessageDescriptor *input;
  const Apigee_ProtobufCMessageDescriptor *output;
};
struct Apigee__ProtobufCServiceDescriptor
{
  uint32_t magic;

  const char *name;
  const char *short_name;
  const char *c_name;
  const char *package;
  unsigned n_methods;
  const Apigee_ProtobufCMethodDescriptor *methods;		// sorted by name
};

typedef struct Apigee__ProtobufCService Apigee_ProtobufCService;
typedef void (*Apigee_ProtobufCClosure)(const Apigee_ProtobufCMessage *message,
                                 void                   *closure_data);
struct Apigee__ProtobufCService
{
  const Apigee_ProtobufCServiceDescriptor *descriptor;
  void (*invoke)(Apigee_ProtobufCService *service,
                 unsigned          method_index,
                 const Apigee_ProtobufCMessage *input,
                 Apigee_ProtobufCClosure  closure,
                 void             *closure_data);
  void (*destroy) (Apigee_ProtobufCService *service);
};


void Apigee_protobuf_c_service_destroy (Apigee_ProtobufCService *);


/* --- querying the descriptors --- */
const Apigee_ProtobufCEnumValue *
Apigee_protobuf_c_enum_descriptor_get_value_by_name
                         (const Apigee_ProtobufCEnumDescriptor    *desc,
                          const char                       *name);
const Apigee_ProtobufCEnumValue *
Apigee_protobuf_c_enum_descriptor_get_value
                         (const Apigee_ProtobufCEnumDescriptor    *desc,
                          int                               value);
const Apigee_ProtobufCFieldDescriptor *
Apigee_protobuf_c_message_descriptor_get_field_by_name
                         (const Apigee_ProtobufCMessageDescriptor *desc,
                          const char                       *name);
const Apigee_ProtobufCFieldDescriptor *
Apigee_protobuf_c_message_descriptor_get_field
                         (const Apigee_ProtobufCMessageDescriptor *desc,
                          unsigned                          value);
const Apigee_ProtobufCMethodDescriptor *
Apigee_protobuf_c_service_descriptor_get_method_by_name
                         (const Apigee_ProtobufCServiceDescriptor *desc,
                          const char                       *name);

/* --- wire format enums --- */
typedef enum
{
  Apigee_PROTOBUF_C_WIRE_TYPE_VARINT,
  Apigee_PROTOBUF_C_WIRE_TYPE_64BIT,
  Apigee_PROTOBUF_C_WIRE_TYPE_LENGTH_PREFIXED,
  Apigee_PROTOBUF_C_WIRE_TYPE_START_GROUP,     /* unsupported */
  Apigee_PROTOBUF_C_WIRE_TYPE_END_GROUP,       /* unsupported */
  Apigee_PROTOBUF_C_WIRE_TYPE_32BIT
} Apigee_ProtobufCWireType;

/* --- unknown message fields --- */
struct Apigee__ProtobufCMessageUnknownField
{
  uint32_t tag;
  Apigee_ProtobufCWireType wire_type;
  size_t len;
  uint8_t *data;
};

/* --- extra (superfluous) api:  trivial buffer --- */
typedef struct Apigee__ProtobufCBufferSimple Apigee_ProtobufCBufferSimple;
struct Apigee__ProtobufCBufferSimple
{
  Apigee_ProtobufCBuffer base;
  size_t alloced;
  size_t len;
  uint8_t *data;
  Apigee_protobuf_c_boolean must_free_data;
};
#define Apigee_PROTOBUF_C_BUFFER_SIMPLE_INIT(array_of_bytes) \
{ { Apigee_protobuf_c_buffer_simple_append }, \
  sizeof(array_of_bytes), 0, (array_of_bytes), 0 }
#define Apigee_PROTOBUF_C_BUFFER_SIMPLE_CLEAR(simp_buf) \
  do { if ((simp_buf)->must_free_data) \
         Apigee_protobuf_c_default_allocator.free (&Apigee_protobuf_c_default_allocator.allocator_data, (simp_buf)->data); } while (0)

/* ====== private ====== */
#include "protobuf-c-private.h"

Apigee_PROTOBUF_C_END_DECLS

#endif /* __PROTOBUF_C_RUNTIME_H_ */
