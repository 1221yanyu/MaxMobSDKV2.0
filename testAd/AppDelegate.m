//
//  AppDelegate.m
//  testAd
//
//  Created by Jacob on 15/12/10.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
//    [NSThread sleepForTimeInterval:2.0];
    NSString *defaultImgName = @"Default";
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:defaultImgName]];
    NSString *PublishID = @"M3xudWxsfDB8MA==";
    NSString *PlacementID = @"MTB8M3wyNXwz";
        maxmobSplashAdView = [[MaxMobSplashAdView alloc] initSplashAd:PublishID placement:PlacementID orientation:Orientation_Portrait window:self.window background:bgColor delegate:self];
    [maxmobSplashAdView startSpalsh];
    return YES;
}
- (void)didAdReceived:(id)view withStatus:(NSString*)resultStatus{//when finished requesting a ad, then callback this method, return status.
    NSLog(@"result status is: %@", resultStatus);
}

- (void)onClicked:(id)view toWhere:(NSString *)toWhere{//when user clicked the view, then callback this method, 'toWhere' means the
    NSLog(@"toWhere is: %@", toWhere);
}

- (void)willDismissScreen:(id)view{//when user clicked the done button from webview, then callback this method.
    NSLog(@"Come back to ad view.");
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
