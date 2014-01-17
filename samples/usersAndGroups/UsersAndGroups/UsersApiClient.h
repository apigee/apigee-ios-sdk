//
//  UsersApiClient.h
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApigeeiOSSDK/Apigee.h>

@interface UsersApiClient : NSObject

//object for initializing the App Services SDK
@property (strong, nonatomic) ApigeeClient *apigeeClient;

//client object for Apigee App Monitoring methods
@property (strong, nonatomic) ApigeeMonitoringClient *monitoringClient;

//client object for App Services data methods
@property (strong, nonatomic) ApigeeDataClient *dataClient;

- (id)initWithApigeeClient:(ApigeeClient *)client;

- (BOOL)addUser:(NSString *)userName
           name:(NSString *)name
          email:(NSString *)email
       password:(NSString *)password;
- (NSMutableArray *)loadUserData;
- (BOOL)addGroup:(NSString *)name
            path:(NSString *)path;
- (BOOL)addUserToGroup:(NSString *)userName
                  path:(NSString *)selectedGroup;
- (NSMutableArray *)loadGroupsForUser:(NSString *)userName;
- (NSMutableArray *)loadAllGroups;

@end
