#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;

- (IBAction)buttonTouch:(id)sender {
    NSLog(@"sending notification through app services");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate sendMyselfAPushNotification: @"You pushed the button!"];
    NSLog(@"notification sent through app services");
}
@end
