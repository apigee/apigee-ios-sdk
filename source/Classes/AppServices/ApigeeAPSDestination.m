//
//  ApigeeAPSDestination.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

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
    destination.deliveryPath = @"devices;ql=*";
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
