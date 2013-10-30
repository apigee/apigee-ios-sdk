#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;
@synthesize buttonAllDevices;
@synthesize buttonThisDevice;

- (void)enableButtons:(BOOL)enabled
{
    self.buttonAllDevices.enabled = enabled;
    self.buttonThisDevice.enabled = enabled;
}

- (IBAction)pushToMyDevice:(id)sender {
    NSLog(@"sending notification through app services");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self enableButtons:NO];
    __weak ViewController* weakSelf = self;

    [appDelegate sendMyselfAPushNotification:@"You pushed the button!"
     completionHandler:^(ApigeeClientResponse *response) {
         if ([response completedSuccessfully]) {
             NSLog(@"notification sent through app services");
         } else {
             NSLog(@"error: unable to send notification");
         }
         
         [weakSelf enableButtons:YES];
     }];
}

- (IBAction)pushToAllDevices:(id)sender {
    NSLog(@"sending notification through app services");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self enableButtons:NO];
    __weak ViewController* weakSelf = self;
    
    [appDelegate sendPushNotificationToAllDevices:@"You pushed the button!"
     completionHandler:^(ApigeeClientResponse *response) {
         if ([response completedSuccessfully]) {
             NSLog(@"notification sent through app services");
         } else {
             NSLog(@"error: unable to send notification");
         }
         
         [weakSelf enableButtons:YES];
     }];
}


@end
