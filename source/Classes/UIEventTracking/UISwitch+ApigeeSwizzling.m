/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
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


