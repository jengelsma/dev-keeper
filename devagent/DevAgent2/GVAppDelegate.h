//
//  GVAppDelegate.h
//  DevAgent2
//
//  Created by Jonathan Engelsma on 9/22/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,readonly) int networkActivityCounter;
-(void) incrementNetworkActivity;
-(void) decrementNetworkActivity;
-(void) resetNetworkActivity;
- (NSString *) retrieveDeviceId;
@end
