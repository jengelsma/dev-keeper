//
//  GVAppDelegate.m
//  DevAgent2
//
//  Created by Jonathan Engelsma on 9/22/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVAppDelegate.h"
#import <Parse/Parse.h>
#import "GVViewController.h"

#define PARSE_APP_ID @"3k6jFJ5IYcetRe6tQ24yGms0P78RQuQYXy48idyP"
#define PARSE_CLIENT_ID @"yJWzDV3D3p2itdpc86rEYkcpVOLf6pQqdU05qa3m"

@implementation GVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Parse setApplicationId:PARSE_APP_ID
                  clientKey:PARSE_CLIENT_ID];
    // Register for Push Notitications, if running iOS 8
    /*
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
     */
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    //}
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    NSString *deviceId = [self retrieveDeviceId];
    currentInstallation.channels = @[ deviceId ];
    [currentInstallation saveInBackground];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    NSLog(@"You just got notified!");
    NSString *key = @"device_id";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"the data" forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME  object:nil userInfo:dictionary];

}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
//    // Create empty photo object
//    NSString *photoId = [userInfo objectForKey:@"p"];
//    PFObject *targetPhoto = [PFObject objectWithoutDataWithClassName:@"Photo"
//                                                            objectId:photoId];
//
//}

-(void) incrementNetworkActivity
{
    _networkActivityCounter += 1;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void) decrementNetworkActivity{
    
    if(_networkActivityCounter > 0) {
        _networkActivityCounter -= 1;
    }
    if(_networkActivityCounter == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }    
}

-(void) resetNetworkActivity
{
    _networkActivityCounter = 0;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}

- (NSString *) retrieveDeviceId
{
    NSString *deviceId = nil;
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"edu.gvsu.cis.DevKeeper" create:NO];
    //NSLog([pasteboard string]);
    if(pasteboard != nil) {
        deviceId = [pasteboard string];
        NSLog(@"unique device ID = %@", deviceId);
    } else {
        
        //Create a unique id as a string
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        
        //create a new pasteboard with a unique identifier
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"edu.gvsu.cis.DevKeeper" create:YES];
        
        [pasteboard setPersistent:YES];
        
        //save the unique identifier string that we created earlier
        deviceId = ((__bridge NSString*)string);
        [pasteboard setString:deviceId];
        
        NSLog(@"newly generated device ID = %@", deviceId);
        
    }
    return deviceId;
}


@end
