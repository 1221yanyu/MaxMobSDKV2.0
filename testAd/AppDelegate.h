//
//  AppDelegate.h
//  testAd
//
//  Created by Jacob on 15/12/10.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaxMobSplashAdView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,MaxMobSplashAdControllerDelegate>
{
    MaxMobSplashAdView *maxmobSplashAdView;
}

@property (strong, nonatomic) UIWindow *window;


@end

