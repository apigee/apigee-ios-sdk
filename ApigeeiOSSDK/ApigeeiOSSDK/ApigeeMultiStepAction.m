#import "ApigeeMultiStepAction.h"

@implementation ApigeeMultiStepAction

@synthesize transactionID;
@synthesize nextAction;
@synthesize userID;
@synthesize groupID;
@synthesize activity;
@synthesize outwardTransactionID;
@synthesize reportToClient;


-(id)init
{
    self = [super init];
    if ( self )
    {
        reportToClient = NO;
    }
    return self;
}
@end
