//
//  ApigeeHTTPResult.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeHTTPResult.h"
#import "ApigeeJsonUtils.h"

@implementation ApigeeHTTPResult

- (id) object {
    if (!_object && !_error) {
        NSError *error;
        _object = [ApigeeJsonUtils decodeData:_data error:&error];
        _error = error;
        if (_error) {
            NSLog(@"JSON ERROR: %@", [error description]);
        }
    }
    return _object;
}

- (NSString *) UTF8String {
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

@end