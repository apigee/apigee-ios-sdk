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

#import "ApigeeUIEventButtonPress.h"
#import "ApigeeUIEventManager.h"


// Approach in this file based on what's described at:
// http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html

void (*gOrigUIApplicationSendAction)(id, SEL, SEL, id, id, UIEvent*) = NULL;
static void OverrideUIApplicationSendAction(UIApplication* self, SEL _cmd, SEL action, id target, id sender, UIEvent* event);


@implementation UIApplication (ApigeeSwizzling)

+ (void)setUpApigeeSwizzling
{
    Method origMethod = class_getInstanceMethod(self, @selector(sendAction:to:from:forEvent:));
    gOrigUIApplicationSendAction = (void *)method_getImplementation(origMethod);
    if( !class_addMethod(self,
                         @selector(sendAction:to:from:forEvent:),
                         (IMP)OverrideUIApplicationSendAction,
                         method_getTypeEncoding(origMethod)) )
    {
        method_setImplementation(origMethod, (IMP)OverrideUIApplicationSendAction);
    }
}

@end

static void OverrideUIApplicationSendAction(UIApplication* self, SEL _cmd, SEL action, id target, id sender, UIEvent* event)
{
    if( [self isKindOfClass:[UIApplication class]] )
    {
        UIEventType eventType = event.type;
        
        if( (eventType == UIEventTypeTouches) &&
           [target isKindOfClass:[UIBarButtonItem class]])
        {
            UIBarButtonItem* barButtonItem = (UIBarButtonItem*) target;
            
            ApigeeUIEventButtonPress* buttonPressEvent =
                [[ApigeeUIEventButtonPress alloc] init];
            
            buttonPressEvent.eventTime = [NSDate date];
            buttonPressEvent.isBarButton = YES;
            
            NSString* title = barButtonItem.title;
            if( [title length] > 0 )
            {
                buttonPressEvent.buttonTitle = title;
            }
            
            if( barButtonItem.tag > 0 )
            {
                buttonPressEvent.tag = (int) barButtonItem.tag;
            }
            
            [[ApigeeUIEventManager sharedInstance] notifyButtonPress:buttonPressEvent];
        }
        
        if( NULL != gOrigUIApplicationSendAction )
        {
            // call original IMP
            gOrigUIApplicationSendAction(self,_cmd,action,target,sender,event);
        }
    }
}

