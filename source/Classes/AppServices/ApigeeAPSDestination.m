/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ApigeeAPSDestination.h"

@interface ApigeeAPSDestination ()

@property (strong,readwrite) NSString* deliveryPath;

@end


@implementation ApigeeAPSDestination

@synthesize deliveryPath=_deliveryPath;

+ (NSString*)constructPathForType:(NSString*)collectionType
                        usingList:(NSArray*)listOfIds
{
    NSMutableString* path = [[NSMutableString alloc] init];
    [path appendString:collectionType];
    [path appendString:@"/"];
    BOOL firstElement = YES;
    
    for (NSString* elementId in listOfIds) {
        if (firstElement) {
            firstElement = NO;
        } else {
            [path appendString:@";"];
        }
        [path appendString:elementId];
    }
    
    return path;
}

+ (ApigeeAPSDestination*)destinationAllDevices
{
    ApigeeAPSDestination* destination = [[ApigeeAPSDestination alloc] init];
    destination.deliveryPath = @"devices/*";
    return destination;
}

+ (ApigeeAPSDestination*)destinationSingleDevice:(NSString*)deviceUUID
{
    ApigeeAPSDestination* destination = [[ApigeeAPSDestination alloc] init];
    destination.deliveryPath = [NSString stringWithFormat:@"devices/%@",
                                deviceUUID];
    return destination;
}

+ (ApigeeAPSDestination*)destinationMultipleDevices:(NSArray*)listOfDeviceUUID
{
    ApigeeAPSDestination* destination = [[ApigeeAPSDestination alloc] init];
    destination.deliveryPath =
        [ApigeeAPSDestination constructPathForType:@"devices"
                                         usingList:listOfDeviceUUID];
    return destination;
}

+ (ApigeeAPSDestination*)destinationSingleUser:(NSString*)userName
{
    ApigeeAPSDestination* destination = [[ApigeeAPSDestination alloc] init];
    destination.deliveryPath = [NSString stringWithFormat:@"users/%@",
                                userName];
    return destination;
}

+ (ApigeeAPSDestination*)destinationMultipleUsers:(NSArray*)listOfUserNames
{
    ApigeeAPSDestination* destination = [[ApigeeAPSDestination alloc] init];
    destination.deliveryPath =
        [ApigeeAPSDestination constructPathForType:@"users"
                                         usingList:listOfUserNames];
    return destination;
}

+ (ApigeeAPSDestination*)destinationSingleGroup:(NSString*)groupName
{
    ApigeeAPSDestination* destination = [[ApigeeAPSDestination alloc] init];
    destination.deliveryPath = [NSString stringWithFormat:@"groups/%@",
                                groupName];
    return destination;
}

+ (ApigeeAPSDestination*)destinationMultipleGroups:(NSArray*)listOfGroupNames
{
    ApigeeAPSDestination* destination = [[ApigeeAPSDestination alloc] init];
    destination.deliveryPath =
        [ApigeeAPSDestination constructPathForType:@"groups"
                                         usingList:listOfGroupNames];
    return destination;
}

@end
