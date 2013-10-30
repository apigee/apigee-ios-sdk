#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)pushToMyDevice:(id)sender;
- (IBAction)pushToAllDevices:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *buttonThisDevice;
@property (weak, nonatomic) IBOutlet UIButton *buttonAllDevices;

@end
