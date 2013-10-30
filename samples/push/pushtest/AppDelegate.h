#import <UIKit/UIKit.h>
#import <ApigeeiOSSDK/Apigee.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)sendMyselfAPushNotification:(NSString *)message completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;
- (void)sendPushNotificationToAllDevices:(NSString *)message
                       completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

@end
