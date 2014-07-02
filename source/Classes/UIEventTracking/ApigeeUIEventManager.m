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

#import "ApigeeUIEventManager.h"

#import "ApigeeUIEventManager.h"
#import "ApigeeUIEventListener.h"
#import "ApigeeUIEventButtonPress.h"
#import "ApigeeUIEventScreenVisibility.h"
#import "ApigeeUIEventSwitchToggled.h"
#import "ApigeeUIEventSegmentSelected.h"
#import "UIApplication+ApigeeSwizzling.h"
#import "UIViewController+ApigeeSwizzling.h"
#import "UIButton+ApigeeSwizzling.h"
#import "UISwitch+ApigeeSwizzling.h"
#import "UISegmentedControl+ApigeeSwizzling.h"

@implementation ApigeeUIEventManager

@synthesize listListeners=_listListeners;
@synthesize nibName=_nibName;

+ (ApigeeUIEventManager*)sharedInstance
{
    static ApigeeUIEventManager *uiEventManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uiEventManager = [[ApigeeUIEventManager alloc] init];
    });
    
    return uiEventManager;
}

- (id)init
{
    self = [super init];
    if( self )
    {
        self.listListeners = [[NSMutableArray alloc] init];
        
        UIDevice* device = [UIDevice currentDevice];
        if( device.userInterfaceIdiom == UIUserInterfaceIdiomPhone )
        {
            _isOnIphone = YES;
        }
        else
        {
            _isOnIphone = NO;
        }
    }
    
    return self;
}

- (void)addUIEventListener:(id<ApigeeUIEventListener>)listener
{
    @synchronized(self.listListeners)
    {
        [self.listListeners addObject:listener];
    }
}

- (void)removeUIEventListener:(id<ApigeeUIEventListener>)listener
{
    @synchronized(self.listListeners)
    {
        [self.listListeners removeObject:listener];
    }
}

- (void)checkNibName:(ApigeeUIControlEvent*)controlEvent
{
    if( _isOnIphone &&
       ([controlEvent.nibName length] == 0) &&
       ([self.nibName length] > 0) )
    {
        controlEvent.nibName = self.nibName;
    }
}

- (void)notifyButtonPress:(ApigeeUIEventButtonPress*)buttonPressEvent
{
    @synchronized(self.listListeners)
    {
        if( [self.listListeners count] > 0 )
        {
            [self checkNibName:buttonPressEvent];
            
            for( NSObject<ApigeeUIEventListener>* listener in self.listListeners )
            {
                if( [listener respondsToSelector:@selector(buttonPressed:)] )
                {
                    BOOL invokeOnMainThread = YES;
                    if( [listener respondsToSelector:@selector(invokeOnMainThread)] )
                    {
                        invokeOnMainThread = [listener invokeOnMainThread];
                    }
                    
                    if( invokeOnMainThread )
                    {
                        [listener buttonPressed:buttonPressEvent];
                    }
                    else
                    {
                        [listener performSelectorInBackground:@selector(buttonPressed:)
                                                   withObject:buttonPressEvent];
                    }
                }
            }
        }
    }
}

- (void)notifySwitchToggled:(ApigeeUIEventSwitchToggled*)switchToggledEvent
{
    @synchronized(self.listListeners)
    {
        if( [self.listListeners count] > 0 )
        {
            [self checkNibName:switchToggledEvent];
            
            for( NSObject<ApigeeUIEventListener>* listener in self.listListeners )
            {
                if( [listener respondsToSelector:@selector(switchToggled:)] )
                {
                    BOOL invokeOnMainThread = YES;
                    if( [listener respondsToSelector:@selector(invokeOnMainThread)] )
                    {
                        invokeOnMainThread = [listener invokeOnMainThread];
                    }
                    
                    if( invokeOnMainThread )
                    {
                        [listener switchToggled:switchToggledEvent];
                    }
                    else
                    {
                        [listener performSelectorInBackground:@selector(switchToggled:)
                                                   withObject:switchToggledEvent];
                    }
                }
            }
        }
    }
}

- (void)notifySegmentSelected:(ApigeeUIEventSegmentSelected*)segmentSelectedEvent
{
    @synchronized(self.listListeners)
    {
        if( [self.listListeners count] > 0 )
        {
            [self checkNibName:segmentSelectedEvent];
            
            for( NSObject<ApigeeUIEventListener>* listener in self.listListeners )
            {
                if( [listener respondsToSelector:@selector(segmentSelected:)] )
                {
                    BOOL invokeOnMainThread = YES;
                    if( [listener respondsToSelector:@selector(invokeOnMainThread)] )
                    {
                        invokeOnMainThread = [listener invokeOnMainThread];
                    }
                    
                    if( invokeOnMainThread )
                    {
                        [listener segmentSelected:segmentSelectedEvent];
                    }
                    else
                    {
                        [listener performSelectorInBackground:@selector(segmentSelected:)
                                                   withObject:segmentSelectedEvent];
                    }
                }
            }
        }
    }
}

- (void)notifyScreenVisibilityChange:(ApigeeUIEventScreenVisibility*)screenVisibilityEvent
{
    if( screenVisibilityEvent.isVisible && _isOnIphone )
    {
        self.nibName = screenVisibilityEvent.nibName;
    }
    
    @synchronized(self.listListeners)
    {
        for( NSObject<ApigeeUIEventListener>* listener in self.listListeners )
        {
            if( [listener respondsToSelector:@selector(screenVisibilityChanged:)] )
            {
                BOOL invokeOnMainThread = YES;
                if( [listener respondsToSelector:@selector(invokeOnMainThread)] )
                {
                    invokeOnMainThread = [listener invokeOnMainThread];
                }
                
                if( invokeOnMainThread )
                {
                    [listener screenVisibilityChanged:screenVisibilityEvent];
                }
                else
                {
                    [listener performSelectorInBackground:@selector(screenVisibilityChanged:)
                                               withObject:screenVisibilityEvent];
                }
            }
        }
    }
}

- (void)setUpApigeeSwizzling
{
    if ([UIApplication respondsToSelector:@selector(setUpApigeeSwizzling)]) {
        [UIApplication setUpApigeeSwizzling];
    }

    if ([UIViewController respondsToSelector:@selector(setUpApigeeSwizzling)]) {
        [UIViewController setUpApigeeSwizzling];
    }

    if ([UIButton respondsToSelector:@selector(setUpApigeeSwizzling)]) {
        [UIButton setUpApigeeSwizzling];
    }

    if ([UISwitch respondsToSelector:@selector(setUpApigeeSwizzling)]) {
        [UISwitch setUpApigeeSwizzling];
    }

    if ([UISegmentedControl respondsToSelector:@selector(setUpApigeeSwizzling)]) {
        [UISegmentedControl setUpApigeeSwizzling];
    }
}

@end
