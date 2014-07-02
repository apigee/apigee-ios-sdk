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

#import "ApigeeMonitoringOptions.h"

@implementation ApigeeMonitoringOptions

@synthesize monitoringEnabled;
@synthesize crashReportingEnabled;
@synthesize interceptNetworkCalls;
@synthesize interceptNSURLSessionCalls;
@synthesize autoPromoteLoggedErrors;
@synthesize showDebuggingInfo;
@synthesize uploadListener;
@synthesize customUploadUrl;
@synthesize performAutomaticUIEventTracking;
@synthesize alwaysUploadCrashReports;

- (id)init
{
    self = [super init];
    if( self )
    {
        self.monitoringEnabled = YES;
        self.crashReportingEnabled = YES;
        self.interceptNetworkCalls = YES;
        self.interceptNSURLSessionCalls = NO;
        self.autoPromoteLoggedErrors = YES;
        self.showDebuggingInfo = NO;
        self.uploadListener = nil;
        self.customUploadUrl = nil;
        self.performAutomaticUIEventTracking = NO;
        self.alwaysUploadCrashReports = YES;
    }
    
    return self;
}

@end
