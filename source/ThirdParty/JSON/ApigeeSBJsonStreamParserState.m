/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#if !__has_feature(objc_arc)
#error "This source file must be compiled with ARC enabled!"
#endif

#import "ApigeeSBJsonStreamParserState.h"

#define SINGLETON \
+ (id)sharedInstance { \
    static id state = nil; \
    if (!state) { \
        @synchronized(self) { \
            if (!state) state = [[self alloc] init]; \
        } \
    } \
    return state; \
}

@implementation ApigeeSBJsonStreamParserState

+ (id)sharedInstance { return nil; }

- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
	return NO;
}

- (ApigeeSBJsonStreamParserStatus)parserShouldReturn:(ApigeeSBJsonStreamParser*)parser {
	return ApigeeSBJsonStreamParserWaitingForData;
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {}

- (BOOL)needKey {
	return NO;
}

- (NSString*)name {
	return @"<aaiie!>";
}

- (BOOL)isError {
    return NO;
}

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateStart

SINGLETON

- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
	return token == Apigee_sbjson_token_array_open || token == Apigee_sbjson_token_object_open;
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {

	ApigeeSBJsonStreamParserState *state = nil;
	switch (tok) {
		case Apigee_sbjson_token_array_open:
			state = [ApigeeSBJsonStreamParserStateArrayStart sharedInstance];
			break;

		case Apigee_sbjson_token_object_open:
			state = [ApigeeSBJsonStreamParserStateObjectStart sharedInstance];
			break;

		case Apigee_sbjson_token_array_close:
		case Apigee_sbjson_token_object_close:
			if (parser.supportMultipleDocuments)
				state = parser.state;
			else
				state = [ApigeeSBJsonStreamParserStateComplete sharedInstance];
			break;

		case Apigee_sbjson_token_eof:
			return;

		default:
			state = [ApigeeSBJsonStreamParserStateError sharedInstance];
			break;
	}


	parser.state = state;
}

- (NSString*)name { return @"before outer-most array or object"; }

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateComplete

SINGLETON

- (NSString*)name { return @"after outer-most array or object"; }

- (ApigeeSBJsonStreamParserStatus)parserShouldReturn:(ApigeeSBJsonStreamParser*)parser {
	return ApigeeSBJsonStreamParserComplete;
}

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateError

SINGLETON

- (NSString*)name { return @"in error"; }

- (ApigeeSBJsonStreamParserStatus)parserShouldReturn:(ApigeeSBJsonStreamParser*)parser {
	return ApigeeSBJsonStreamParserError;
}

- (BOOL)isError {
    return YES;
}

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateObjectStart

SINGLETON

- (NSString*)name { return @"at beginning of object"; }

- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
	switch (token) {
		case Apigee_sbjson_token_object_close:
		case Apigee_sbjson_token_string:
        case Apigee_sbjson_token_encoded:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {
	parser.state = [ApigeeSBJsonStreamParserStateObjectGotKey sharedInstance];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateObjectGotKey

SINGLETON

- (NSString*)name { return @"after object key"; }

- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
	return token == Apigee_sbjson_token_entry_sep;
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {
	parser.state = [ApigeeSBJsonStreamParserStateObjectSeparator sharedInstance];
}

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateObjectSeparator

SINGLETON

- (NSString*)name { return @"as object value"; }

- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
	switch (token) {
		case Apigee_sbjson_token_object_open:
		case Apigee_sbjson_token_array_open:
		case Apigee_sbjson_token_bool:
		case Apigee_sbjson_token_null:
        case Apigee_sbjson_token_integer:
        case Apigee_sbjson_token_real:
        case Apigee_sbjson_token_string:
        case Apigee_sbjson_token_encoded:
			return YES;
			break;

		default:
			return NO;
			break;
	}
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {
	parser.state = [ApigeeSBJsonStreamParserStateObjectGotValue sharedInstance];
}

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateObjectGotValue

SINGLETON

- (NSString*)name { return @"after object value"; }

- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
	switch (token) {
		case Apigee_sbjson_token_object_close:
        case Apigee_sbjson_token_value_sep:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {
	parser.state = [ApigeeSBJsonStreamParserStateObjectNeedKey sharedInstance];
}


@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateObjectNeedKey

SINGLETON

- (NSString*)name { return @"in place of object key"; }

- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
    return Apigee_sbjson_token_string == token || Apigee_sbjson_token_encoded == token;
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {
	parser.state = [ApigeeSBJsonStreamParserStateObjectGotKey sharedInstance];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateArrayStart

SINGLETON

- (NSString*)name { return @"at array start"; }

- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
	switch (token) {
		case Apigee_sbjson_token_object_close:
        case Apigee_sbjson_token_entry_sep:
        case Apigee_sbjson_token_value_sep:
			return NO;
			break;

		default:
			return YES;
			break;
	}
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {
	parser.state = [ApigeeSBJsonStreamParserStateArrayGotValue sharedInstance];
}

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateArrayGotValue

SINGLETON

- (NSString*)name { return @"after array value"; }


- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
	return token == Apigee_sbjson_token_array_close || token == Apigee_sbjson_token_value_sep;
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {
	if (tok == Apigee_sbjson_token_value_sep)
		parser.state = [ApigeeSBJsonStreamParserStateArrayNeedValue sharedInstance];
}

@end

#pragma mark -

@implementation ApigeeSBJsonStreamParserStateArrayNeedValue

SINGLETON

- (NSString*)name { return @"as array value"; }


- (BOOL)parser:(ApigeeSBJsonStreamParser*)parser shouldAcceptToken:(Apigee_sbjson_token_t)token {
	switch (token) {
		case Apigee_sbjson_token_array_close:
        case Apigee_sbjson_token_entry_sep:
		case Apigee_sbjson_token_object_close:
		case Apigee_sbjson_token_value_sep:
			return NO;
			break;

		default:
			return YES;
			break;
	}
}

- (void)parser:(ApigeeSBJsonStreamParser*)parser shouldTransitionTo:(Apigee_sbjson_token_t)tok {
	parser.state = [ApigeeSBJsonStreamParserStateArrayGotValue sharedInstance];
}

@end

