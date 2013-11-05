//
//  UISwitch+ApigeeSwizzling.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/objc.h>

#import "ApigeeUIEventManager.h"
#import "ApigeeUIEventSwitchToggled.h"

void (*gOrigUISwitchSendAction)(id, SEL, SEL, id, UIEvent*) = NULL;
static void OverrideUISwitchSendAction(UISwitch* self, SEL _cmd, SEL action, id target, UIEvent* event);

@implementation UISwitch (ApigeeSwizzling)

+ (void)setUpApigeeSwizzling
{
    Method origMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    gOrigUISwitchSendAction = (void *)method_getImplementation(origMethod);
    if( !class_addMethod(self,
                         @selector(sendAction:to:forEvent:),
                         (IMP)OverrideUISwitchSendAction,
                         method_getTypeEncoding(origMethod)) )
    {
        method_setImplementation(origMethod, (IMP)OverrideUISwitchSendAction);
    }
}

@end

static void OverrideUISwitchSendAction(UISwitch* self, SEL _cmd, SEL action, id target, UIEvent* event)
{
    if( [self isKindOfClass:[UISwitch class]] )
    {
        UIEventType eventType = event.type;
        
        if( eventType == UIEventTypeTouches )
        {
            ApigeeUIEventSwitchToggled* switchToggledEvent =
                [[ApigeeUIEventSwitchToggled alloc] init];
            
            [switchToggledEvent populateWithControl:self];
            switchToggledEvent.eventTime = [NSDate date];
            switchToggledEvent.switchIsOn = self.on;
            
            [[ApigeeUIEventManager sharedInstance] notifySwitchToggled:switchToggledEvent];
        }
        
        if( NULL != gOrigUISwitchSendAction )
        {
            // call original IMP
            gOrigUISwitchSendAction(self,_cmd,action,target,event);
        }
    }
}


