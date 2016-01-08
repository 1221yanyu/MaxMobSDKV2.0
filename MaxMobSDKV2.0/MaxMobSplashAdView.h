//
//  MaxMobSplashAdView.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/6/2.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//
#define Orientation_Portrait @"portrait"
#define Orientation_Landscape @"landscape"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class MaxMobAdViewManager;
@protocol MaxMobSplashAdControllerDelegate <NSObject>
//请求广告结果返回触发事件,  'view' 广告控件 'resultStatus'返回结果状态

- (void)didAdReceived:(id)view withStatus:(NSString*)resultStatus;


@end


@interface MaxMobSplashAdView : UIView


@property (nonatomic, assign) id <MaxMobSplashAdControllerDelegate> delegate;
@property (nonatomic, assign)UIViewController *controller;
@property (nonatomic, readonly) BOOL isReady;

-(id)initSplashAd:(NSString*) appID  placement:(NSString*) placementID  orientation:(NSString*) orientationStatus window:(UIWindow*)window background:(UIColor *)background delegate:(id<MaxMobSplashAdControllerDelegate>)delegate;


-(void)startSpalsh;
@end
