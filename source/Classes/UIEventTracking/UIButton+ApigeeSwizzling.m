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

#import "ApigeeUIEventButtonPress.h"
#import "ApigeeUIEventManager.h"

// Approach in this file based on what's described at:
// http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html

//static IMP _originalSendActionToForEventMethod = NULL;

void (*gOrigUIButtonSendAction)(id, SEL, SEL, id, UIEvent*) = NULL;
static void OverrideUIButtonSendAction(UIButton* self, SEL _cmd, SEL action, id target, UIEvent* event);


@implementation UIButton (ApigeeSwizzling)

+ (void)setUpApigeeSwizzling
{
    Method origMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    gOrigUIButtonSendAction = (void *)method_getImplementation(origMethod);
    if( !class_addMethod(self,
                         @selector(sendAction:to:forEvent:),
                         (IMP)OverrideUIButtonSendAction,
                         method_getTypeEncoding(origMethod)) )
    {
        method_setImplementation(origMethod, (IMP)OverrideUIButtonSendAction);
    }
}

@end

static void OverrideUIButtonSendAction(UIButton* self, SEL _cmd, SEL action, id target, UIEvent* event)
{
    if( [self isKindOfClass:[UIButton class]] )
    {
        UIEventType eventType = event.type;
        
        if( eventType == UIEventTypeTouches )
        {
            if( [self respondsToSelector:@selector(titleForState:)] )
            {
                ApigeeUIEventButtonPress* buttonPressEvent =
                    [[ApigeeUIEventButtonPress alloc] init];
                
                [buttonPressEvent populateWithControl:self];
                buttonPressEvent.eventTime = [NSDate date];
                
                NSString* title = [self titleForState:UIControlStateNormal];
                if( [title length] > 0 )
                {
                    buttonPressEvent.buttonTitle = title;
                } else {
                    UIButtonType buttonType = self.buttonType;
                    if (buttonType == UIButtonTypeSystem) {
                        buttonPressEvent.buttonTitle = @"(System)";
                    } else if (buttonType == UIButtonTypeDetailDisclosure) {
                        buttonPressEvent.buttonTitle = @"(Detail Disclosure)";
                    } else if (buttonType == UIButtonTypeContactAdd) {
                        buttonPressEvent.buttonTitle = @"(Contact Add)";
                    }
                }
                
                [[ApigeeUIEventManager sharedInstance] notifyButtonPress:buttonPressEvent];
            }
        }
        
        if( NULL != gOrigUIButtonSendAction )
        {
            // call original IMP
            gOrigUIButtonSendAction(self,_cmd,action,target,event);
        }
    }
}

