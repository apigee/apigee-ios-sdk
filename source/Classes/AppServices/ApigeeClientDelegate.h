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
