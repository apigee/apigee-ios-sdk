/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
            segmentSelectedEvent.selectedSegmentIndex = (int)self.selectedSegmentIndex;
            
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

