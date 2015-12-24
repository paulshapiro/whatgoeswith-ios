//
//  WGWAppDelegate.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/20/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWAppDelegate.h"
#import "WGWRootViewController.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants



////////////////////////////////////////////////////////////////////////////////
#pragma mark - C



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWAppDelegate ()



@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WGWAppDelegate


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.tintColor = [UIColor WGWTintColor];
    self.window = window;
    
    WGWRootViewController *controller = [[WGWRootViewController alloc] init];
    _window.rootViewController = controller;
    
    [_window makeKeyAndVisible];
    
    WGWAnalytics_identifyUser(WGWAnalytics_persistedOrNew_installationUUID(),
                              @{});
    
    WGWAnalytics_trackEvent(@"app finished launching", @{});
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    WGWAnalytics_trackEvent(@"app will resign active", @{});

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    WGWAnalytics_trackEvent(@"app did enter bg", @{});

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    WGWAnalytics_trackEvent(@"app will enter foreground", @{});
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    WGWAnalytics_trackEvent(@"app did become active", @{});

    WGWAnalytics_setDateThat_appLastBecameActive(); // AFTER recording app did become active
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    WGWAnalytics_trackEvent(@"app will terminate", @{});
}

@end
