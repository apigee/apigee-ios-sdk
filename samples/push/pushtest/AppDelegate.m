#import "AppDelegate.h"
#import <ApigeeiOSSDK/Apigee.h>
#import <AudioToolbox/AudioToolbox.h>


static NSString *kBundledSoundName = @"Bulletin";
static NSString *kBundledSongFileType = @"m4a";
static NSString *kBundledSoundNameWithExt = @"Bulletin.m4a";

static SystemSoundID nullSoundId = (SystemSoundID) NULL;
static SystemSoundID soundId = (SystemSoundID) NULL;


@implementation AppDelegate

ApigeeDataClient * dataClient;

// The following values must be changed to the organization, application, and notifier
// to match the names that you've created on the App Services platform. Be sure that
<<<<<<< HEAD
// the application you use allows Guest access (e.g., sandbox) - or that you have the device
=======
// the application you use allows Guest access (e.g., sandbox) - or that have the device
>>>>>>> 84e24df741f4572a687b07dd0e97e0a6432a279b
// log in to App Services.
// Also ensure that you update the Bundle Identifier and Provisioning Profile in the project Build Settings.
// You will need to set the "Code Signing Identity" options for "Debug" to your Provisioning Profile.

#warning update your org name, app name, and notifier here
NSString * orgName = @"<YOUR_ORG_NAME>";
NSString * appName = @"<YOUR_APP_NAME>";
NSString * notifier = @"<YOUR_PUSH_NOTIFIER>";

NSString * baseURL = @"https://api.usergrid.com";

- (void)playSound:(NSString*)soundName
{
    if ([soundName length] > 0) {
        if (nullSoundId == soundId) {
            // ignore the soundName parameter, we only know 1 kind of sound
            NSString* soundFilePath =
                [[NSBundle mainBundle] pathForResource:kBundledSoundName
                                                ofType:kBundledSongFileType];

            if (soundFilePath) {
                NSURL* soundURL = [NSURL fileURLWithPath:soundFilePath];

                if (soundURL) {
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL,
                                                     &soundId);
                    if (soundId == nullSoundId) {
                        NSLog(@"error: unable to load sound file");
                    }
                }
            }
        }

        if (soundId != nullSoundId) {
            AudioServicesPlaySystemSound(soundId);
        }
    }
}

- (void)handlePushNotification:(NSDictionary*)dictPushNotification
                forApplication:(UIApplication*)application
{
    // Received a push notification from the server
    NSLog(@"push received: %@", dictPushNotification);

    NSDictionary* payloadAPS = [dictPushNotification valueForKey:@"aps"];
    if (nil == payloadAPS) {
        NSLog(@"error: no aps payload found");
        return;
    }

    UIRemoteNotificationType enabledTypes =
        [application enabledRemoteNotificationTypes];

    NSString* alertText = [payloadAPS valueForKey:@"alert"];

    // enabled for sound?
    if (enabledTypes & UIRemoteNotificationTypeSound) {
        NSString* sound = [payloadAPS valueForKey:@"sound"];

        // play a sound even if we haven't been given a value
        if ([sound length] == 0) {
            sound = kBundledSoundName;
        }

        if ([sound length] > 0) {
            [self playSound:sound];
        }
    }

    // enabled for alerts?
    if (enabledTypes & UIRemoteNotificationTypeAlert) {
        // Only pop alert if applicationState is active (if not, the user already saw the alert)
        if (application.applicationState == UIApplicationStateActive) {
            if ([alertText length] > 0) {
                NSString* message = [NSString stringWithFormat:@"Text:\n%@",
                                     alertText];
                [self alert:message
                      title:@"Remote Notification"];
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Find out what notification types the user has enabled.
    UIRemoteNotificationType enabledTypes =
    [application enabledRemoteNotificationTypes];

    // If the user has enabled alert or sound notifications, then
    // register for those notification types from Apple.
    if (enabledTypes & (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound)) {

        // Register for push notifications with Apple
        NSLog(@"registering for remote notifications");
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
}


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

    if (launchOptions != nil) {
        NSDictionary* userInfo =
            [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo) {
            [self handlePushNotification:userInfo
                          forApplication:application];
        }
    }
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    // It's not necessary to explicitly login to App Services if the Guest role allows access
//    NSLog(@"Logging in user");
//    [usergridClient logInUser: userName password: password];

    NSLog(@"done launching");
    return YES;
}

// Invoked as a callback from calling registerForRemoteNotificationTypes.
// newDeviceToken is a token received from registering with Apple APNs.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Register device token with App Services (will create the Device entity if it doesn't exist)
    NSLog(@"registering token with app services");
    ApigeeClientResponse *response = [dataClient setDevicePushToken: newDeviceToken
                                                        forNotifier: notifier];

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
completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // send to a single device -- our own device
    NSString *deviceId = [ApigeeDataClient getUniqueDeviceID];
    ApigeeAPSDestination* destination =
        [ApigeeAPSDestination destinationSingleDevice:deviceId];

    // set our APS payload
    ApigeeAPSPayload* apsPayload = [[ApigeeAPSPayload alloc] init];
    apsPayload.sound = kBundledSoundNameWithExt;
    apsPayload.alertText = message;

    // Example of what a custom payload might look like -- remember that
    // APNS payloads are limited to a maximum of 256 bytes (for the entire
    // payload -- including the 'aps' part)
    NSMutableDictionary* customPayload = [[NSMutableDictionary alloc] init];
    [customPayload setValue:@"72" forKey:@"degrees"];
    [customPayload setValue:@"3" forKey:@"newOrders"];

    __weak AppDelegate* weakSelf = self;

    // send the push notification
    [dataClient pushAlert:apsPayload
            customPayload:customPayload
              destination:destination
            usingNotifier:notifier
        completionHandler:^(ApigeeClientResponse *response) {
            if ( ! [response completedSuccessfully]) {
                [weakSelf alert:response.rawResponse
                          title: @"Error"];
            }

            if (completionHandler) {
                completionHandler(response);
            }
        }];
}

- (void)sendPushNotificationToAllDevices:(NSString *)message
completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // send to all devices
    ApigeeAPSDestination* destination =
        [ApigeeAPSDestination destinationAllDevices];

    // set our APS payload
    ApigeeAPSPayload* apsPayload = [[ApigeeAPSPayload alloc] init];
    apsPayload.sound = kBundledSoundNameWithExt;
    apsPayload.alertText = message;
    apsPayload.badgeValue = [NSNumber numberWithInt:3];

    __weak AppDelegate* weakSelf = self;

    // send the push notification
    [dataClient pushAlert:apsPayload
              destination:destination
            usingNotifier:notifier
        completionHandler:^(ApigeeClientResponse *response) {
            if ( ! [response completedSuccessfully]) {
                [weakSelf alert:response.rawResponse
                          title: @"Error"];
            }

            if (completionHandler) {
                completionHandler(response);
            }
        }];
}

// Invoked when a notification arrives for this device.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handlePushNotification:userInfo forApplication:application];
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (soundId != nullSoundId) {
        AudioServicesDisposeSystemSoundID(soundId);
    }
}

@end
