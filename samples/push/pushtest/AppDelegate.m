#import "AppDelegate.h"
#import <ApigeeiOSSDK/ApigeeClient.h>
#import <ApigeeiOSSDK/ApigeeDataClient.h>
#import <ApigeeiOSSDK/ApigeeClientResponse.h>

@implementation AppDelegate

ApigeeDataClient * usergridClient;

// The following values must be changed to the organization, application, and notifier
// to match the names that you've created on the App Services platform. Be sure that
// the application you use allows Guest access (eg. sandbox) - or that you have the device
// log in to App Services.
// Also ensure that you update the Bundle Identifier and Provisioning Profile in the project Build Settings.
// You will need to set the "Code Signing Identity" options for "Debug" to your Provisioning Profile.

#error update your org name, app name, and notifier here
NSString * orgName = @"scottganyo";
NSString * appName = @"pushtest";
NSString * notifier = @"apple";

NSString * baseURL = @"https://api.usergrid.com";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"setting up app services connection");
    // connect and login to App Services
    ApigeeClient *apigeeClient =
        [[ApigeeClient alloc] initWithOrganizationId:orgName
                                       applicationId:appName
                                             baseURL:baseURL];
    usergridClient = [apigeeClient dataClient];
    [usergridClient setLogging:true]; //comment out to remove debug output from the console window

    // it's not necessary to explicitly login to App Services if the Guest role allows access
//    NSLog(@"logging in user");
//    [usergridClient logInUser: userName password: password];

    // Register for Push Notifications with Apple
    NSLog(@"registering for remove notifications");
    [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge |
                                                     UIRemoteNotificationTypeAlert |
                                                     UIRemoteNotificationTypeSound];
    NSLog(@"done launching");
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // register device token with App Services (will create the Device entity if it doesn't exist)
    NSLog(@"registering token with app services");
    ApigeeClientResponse *response = [usergridClient setDevicePushToken: newDeviceToken forNotifier: notifier];
    
    // you could use this if you log in as an app services user to associate the Device to your User
//    if (response.transactionState == kUGClientResponseSuccess) {
//        response = [self connectEntities: @"users" connectorID: @"me" type: @"devices" connecteeID: deviceId];
//    }
    
    if ( ! [response completedSuccessfully]) {
        [self alert: response.rawResponse title: @"Error"];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [self alert: error.localizedDescription title: @"Error"];
}

- (void)sendMyselfAPushNotification:(NSString *)message
{
    NSString *deviceId = [ApigeeDataClient getUniqueDeviceID];
    NSString *thisDevice = [@"devices/" stringByAppendingString: deviceId];
    
    ApigeeClientResponse *response = [usergridClient pushAlert: message
                                                 withSound: @"chime"
                                                        to: thisDevice
                                             usingNotifier: notifier];
    if ( ! [response completedSuccessfully]) {
        [self alert: response.rawResponse title: @"Error"];
    }
}

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
