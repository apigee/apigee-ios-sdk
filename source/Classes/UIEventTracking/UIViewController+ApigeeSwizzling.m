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

#include <objc/runtime.h>

#import "ApigeeUIEventManager.h"
#import "ApigeeUIEventScreenVisibility.h"

static char const* const KEY_OBJECT_NAME = "ApigeeName";
static char const* const KEY_OBJECT_START_TIME = "ApigeeStartTime";


@implementation UIViewController (ApigeeSwizzling)

+ (BOOL) swizzleClass:(Class) targetClass
       instanceMethod:(SEL) originalSelector
     replacementClass:(Class) swizzleClass
replacementInstanceMethod:(SEL) replacementSelector
{
    Method origMethod = class_getInstanceMethod(targetClass, originalSelector);
    Method newMethod = class_getInstanceMethod(swizzleClass, replacementSelector);
    method_exchangeImplementations(origMethod, newMethod);
    return YES;
}

+ (void)setUpApigeeSwizzling
{
    Class clsUIViewController = [UIViewController class];
    
    [self swizzleClass:clsUIViewController
        instanceMethod:@selector(initWithNibName:bundle:)
      replacementClass:clsUIViewController
replacementInstanceMethod:@selector(initSwzWithNibName:bundle:)];
    
    [self swizzleClass:clsUIViewController
        instanceMethod:@selector(viewDidAppear:)
      replacementClass:clsUIViewController
replacementInstanceMethod:@selector(swzViewDidAppear:)];
    
    [self swizzleClass:clsUIViewController
        instanceMethod:@selector(viewDidDisappear:)
      replacementClass:clsUIViewController
replacementInstanceMethod:@selector(swzViewDidDisappear:)];
}

- (void)_setName:(NSString*)name
{
    objc_setAssociatedObject(self,
                             KEY_OBJECT_NAME,
                             name,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)_name
{
    return objc_getAssociatedObject(self, KEY_OBJECT_NAME);
}

- (void)_setStartTime:(NSDate*)date
{
    objc_setAssociatedObject(self,
                             KEY_OBJECT_START_TIME,
                             date,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate*)_startTime
{
    return objc_getAssociatedObject(self, KEY_OBJECT_START_TIME);
}

- (id)initSwzWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    id initReturnValue = [self initSwzWithNibName:nibName bundle:nibBundle];
    
    if( initReturnValue )
    {
        if( [nibName length] > 0 )
        {
            //NSLog( @"loading nibName: '%@'", nibName );
            [self _setName:nibName];
        }
    }
    
    return initReturnValue;
}

- (void)swzViewDidAppear:(BOOL)animated
{
    NSString* name = [self _name];
    
    // don't have a name yet, but have a title?
    if( 0 == [name length] )
    {
        if( [self.title length] > 0 )
        {
            // use the title for our name
            [self _setName:self.title];
        }
        else if( [self respondsToSelector:@selector(restorationIdentifier)] &&
                ([self.restorationIdentifier length] > 0) )
        {
            [self _setName:self.restorationIdentifier];
        }
    }
    
    NSDate* now = [NSDate date];
    [self _setStartTime:now];
    
    ApigeeUIEventScreenVisibility* screenVisibilityEvent =
        [[ApigeeUIEventScreenVisibility alloc] init];
    NSBundle* bundle = self.nibBundle;
    if( bundle != nil )
    {
        screenVisibilityEvent.bundleIdentifier = bundle.bundleIdentifier;
    }
    
    screenVisibilityEvent.nibName = self.nibName;
    screenVisibilityEvent.restorationIdentifier = self.restorationIdentifier;
    screenVisibilityEvent.screenTitle = self.title;
    screenVisibilityEvent.eventTime = now;
    screenVisibilityEvent.haveTimeIntervalValue = NO;
    screenVisibilityEvent.timeOnScreen = 0.0;
    screenVisibilityEvent.isVisible = YES;
    
    [[ApigeeUIEventManager sharedInstance] notifyScreenVisibilityChange:screenVisibilityEvent];
    
    //NSLog( @"viewDidAppear %@", self.title );
    [self swzViewDidAppear:animated];
}

- (void)swzViewDidDisappear:(BOOL)animated
{
    NSString* name = [self _name];
    
    // don't have a name yet, but have a title?
    if( 0 == [name length] && [self.title length] > 0 )
    {
        // use the title for our name
        [self _setName:self.title];
    }
    
    NSDate* startTime = [self _startTime];
    
    ApigeeUIEventScreenVisibility* screenVisibilityEvent =
        [[ApigeeUIEventScreenVisibility alloc] init];
    NSBundle* bundle = self.nibBundle;
    if( bundle != nil )
    {
        screenVisibilityEvent.bundleIdentifier = bundle.bundleIdentifier;
    }
    screenVisibilityEvent.nibName = self.nibName;
    screenVisibilityEvent.restorationIdentifier = self.restorationIdentifier;
    screenVisibilityEvent.screenTitle = self.title;
    screenVisibilityEvent.isVisible = NO;
    
    if( startTime != nil )
    {
        NSDate* endTime = [NSDate date];
        NSTimeInterval timeOnScreen = [endTime timeIntervalSinceDate:startTime];
        //NSLog( @"ending screen %@, timeOnScreen = %f seconds", [self _name], timeOnScreen);
        screenVisibilityEvent.haveTimeIntervalValue = YES;
        screenVisibilityEvent.timeOnScreen = timeOnScreen;
        screenVisibilityEvent.eventTime = endTime;
    }
    else
    {
        screenVisibilityEvent.haveTimeIntervalValue = NO;
        screenVisibilityEvent.timeOnScreen = 0.0;
        screenVisibilityEvent.eventTime = [NSDate date];
    }
    
    [[ApigeeUIEventManager sharedInstance] notifyScreenVisibilityChange:screenVisibilityEvent];
    
    //NSLog( @"viewDidDisappear %@", self.title );
    [self swzViewDidDisappear:animated];
}

@end
