//
//  UISegmentedControl+ApigeeSwizzling.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/objc.h>

#import "ApigeeUIEventManager.h"
#import "ApigeeUIEventSegmentSelected.h"

void (*gOrigUISegmentedControlSendAction)(id, SEL, SEL, id, UIEvent*) = NULL;
static void OverrideUISegmentedControlSendAction(UISegmentedControl* self, SEL _cmd, SEL action, id target, UIEvent* event);

@implementation UISegmentedControl (ApigeeSwizzling)

+ (void)setUpApigeeSwizzling
{
    Method origMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    gOrigUISegmentedControlSendAction = (void *)method_getImplementation(origMethod);
    if( !class_addMethod(self,
                         @selector(sendAction:to:forEvent:),
                         (IMP)OverrideUISegmentedControlSendAction,
                         method_getTypeEncoding(origMethod)) )
    {
        method_setImplementation(origMethod, (IMP)OverrideUISegmentedControlSendAction);
    }
}

@end

static void OverrideUISegmentedControlSendAction(UISegmentedControl* self, SEL _cmd, SEL action, id target, UIEvent* event)
{
    if( [self isKindOfClass:[UISegmentedControl class]] )
    {
        UIEventType eventType = event.type;
        
        if( eventType == UIEventTypeTouches )
        {
            ApigeeUIEventSegmentSelected* segmentSelectedEvent =
                [[ApigeeUIEventSegmentSelected alloc] init];
            
            [segmentSelectedEvent populateWithControl:self];
            segmentSelectedEvent.eventTime = [NSDate date];
            segmentSelectedEvent.selectedSegmentIndex = self.selectedSegmentIndex;
            
            NSString* segmentTitle = [self titleForSegmentAtIndex:self.selectedSegmentIndex];
            if( [segmentTitle length] > 0 )
            {
                segmentSelectedEvent.segmentTitle = segmentTitle;
            }
            
            [[ApigeeUIEventManager sharedInstance] notifySegmentSelected:segmentSelectedEvent];
        }
        
        if( NULL != gOrigUISegmentedControlSendAction )
        {
            // call original IMP
            gOrigUISegmentedControlSendAction(self,_cmd,action,target,event);
        }
    }
}

