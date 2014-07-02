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

#import <Foundation/Foundation.h>

/*!
 @protocol ApigeeUploadListener
 @abstract Protocol (listener) to be called when app monitoring uploads occur
 */
@protocol ApigeeUploadListener <NSObject>

/*!
 @abstract Called when metrics are being uploaded to server
 @param metricsPayload the raw payload of metrics being uploaded to server
 */
- (void)onUploadMetrics:(NSString*)metricsPayload;

/*!
 @abstract Called when a crash report is being uploaded to server
 @param crashReportPayload the raw payload of a crash report being uploaded
    to server
 */
- (void)onUploadCrashReport:(NSString*)crashReportPayload;

@end
