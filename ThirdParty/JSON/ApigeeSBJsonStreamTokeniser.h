//
// Created by SuperPappi on 09/01/2013.
//
// To change the template use AppCode | Preferences | File Templates.
//



typedef enum {
    Apigee_sbjson_token_error = -1,
    Apigee_sbjson_token_eof,

    Apigee_sbjson_token_array_open,
    Apigee_sbjson_token_array_close,
    Apigee_sbjson_token_value_sep,

    Apigee_sbjson_token_object_open,
    Apigee_sbjson_token_object_close,
    Apigee_sbjson_token_entry_sep,

    Apigee_sbjson_token_bool,
    Apigee_sbjson_token_null,

    Apigee_sbjson_token_integer,
    Apigee_sbjson_token_real,

    Apigee_sbjson_token_string,
    Apigee_sbjson_token_encoded,
} Apigee_sbjson_token_t;


@interface ApigeeSBJsonStreamTokeniser : NSObject

@property (nonatomic, readonly, copy) NSString *error;

- (void)appendData:(NSData*)data_;
- (Apigee_sbjson_token_t)getToken:(char**)tok length:(NSUInteger*)len;

@end

