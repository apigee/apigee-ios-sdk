#import "AppDelegate.h"
#import <ApigeeiOSSDK/Apigee.h>

@implementation AppDelegate

ApigeeDataClient * dataClient;

// The following values must be changed to the organization, application, and notifier
// to match the names that you've created on the App Services platform. Be sure that
// the application you use allows Guest access (e.g., sandbox) - or that you have the device
// log in to App Services.
// Also ensure that you update the Bundle Identifier and Provisioning Profile in the project Build Settings.
// You will need to set the "Code Signing Identity" options for "Debug" to your Provisioning Profile.

#error update your org name, app name, and notifier here
NSString * orgName = @"<YOUR_ORG_NAME>";
NSString * appName = @"<YOUR_APP_NAME>";
NSString * notifier = @"<YOUR_PUSH_NOTIFIER>";

NSString * baseURL = @"https://api.usergrid.com";

// Invoked as a callback after the application launches. 
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"setting up app services connection");
    // Connect and login to App Services
    ApigeeClient *apigeeClient =
        [[ApigeeClient alloc] initWithOrganizationId:orgName
                                       applicationId:appName
                                             baseURL:baseURL];
    dataClient = [apigeeClient dataClient];
    [dataClient setLogging:true]; //comment out to remove debug output from the console window

    // It's not necessary to explicitly login to App Services if the Guest role allows access
//    NSLog(@"Logging in user");
//    [usergridClient logInUser: userName password: password];

    // Register for push notifications with Apple
    NSLog(@"registering for remote notifications");
    [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge |
                                                     UIRemoteNotificationTypeAlert |
                                                     UIRemoteNotificationTypeSound];
    NSLog(@"done launching");
    return YES;
}

// Invoked as a callback from calling registerForRemoteNotificationTypes. 
// newDeviceToken is a token received from registering with Apple APNs.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Register device token with App Services (will create the Device entity if it doesn't exist)
    NSLog(@"registering token with app services");
    ApigeeClientResponse *response = [dataClient setDevicePushToken: newDeviceToken forNotifier: notifier];
    
    // You could use this if you log in as an app services user to associate the Device to your User
//    if (response.transactionState == kUGClientResponseSuccess) {
//        response = [self connectEntities: @"users" connectorID: @"me" type: @"devices" connecteeID: deviceId];
//    }
    
    if ( ! [response completedSuccessfully]) {
        [self alert: response.rawResponse title: @"Error"];
    }
}

// Invoked as a callback from calling registerForRemoteNotificationTypes if registration 
// failed.
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [self alert: error.localizedDescription title: @"Error"];
}

- (void)sendMyselfAPushNotification:(NSString *)message
{
    NSString *deviceId = [ApigeeDataClient getUniqueDeviceID];
    NSString *thisDevice = [@"devices/" stringByAppendingString: deviceId];
    
    ApigeeClientResponse *response = [dataClient pushAlert: message
                                                 withSound: @"chime"
                                                        to: thisDevice
                                             usingNotifier: notifier];
    if ( ! [response completedSuccessfully]) {
        [self alert: response.rawResponse title: @"Error"];
    }
}

// Invoked when a notification arrives for this device.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Received a push notification from the server
    // Only pop alert if applicationState is active (if not, the user already saw the alert)
    if (application.applicationState == UIApplicationStateActive)
    {
        NSString * message = [NSString stringWithFormat:@"Text:\n%@",
                              [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
        [self alert: message title: @"Remote Notification"];
    }
}

- (void)alert:(NSString *)message title:(NSString *)title
{
    NSLog(@"displaying alert. title: %@, message: %@", title, message);
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle: title
                              message: message
                              delegate: self
                              cancelButtonTitle: @"OK"
                              otherButtonTitles: nil];
    [alertView show];
}

@end
