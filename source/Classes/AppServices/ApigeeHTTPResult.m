//
//  ApigeeHTTPResult.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeHTTPResult.h"

@implementation ApigeeHTTPResult

- (id) object {
    if (!_object && !_error) {
        NSError *error;
        // NSLog(@"JSON %@", [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding]);
        _object = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
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