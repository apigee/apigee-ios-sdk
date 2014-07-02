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
#import "ApigeeClientResponse.h"

/*!
 @protocol ApigeeClientDelegate
 @abstract Objects conform to this protocol to take advantage of the Asynchronous
    SDK functionality.
 @discussion The setDelegate method needs to be called on the current
    ApigeeDataClient for this function to be called on an implemented delegate.
    If you do not set a delegate, all functions will run synchronously, blocking
    until a response has been received or an error detected.
 */
@protocol ApigeeClientDelegate <NSObject>

/*!
 @abstract This method is called after every request to the Usergrid API.
 @param response The response to the API request
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(void)apigeeClientResponse:(ApigeeClientResponse *)response;

@end
