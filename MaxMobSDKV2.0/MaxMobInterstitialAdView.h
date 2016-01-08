//
//  MaxMobInterstitialAdViewController.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/13.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MaxMobAdViewManager;
@protocol MaxMobInterstitialAdControllerDelegate <NSObject>
//请求广告结果返回触发事件,  'view' 广告控件 'resultStatus'返回结果状态

- (void)didAdReceived:(id)view withStatus:(NSString*)resultStatus;


// 当用户点击了'Done'按键时，将要返回到广告控件的view, 'view' 广告控件

- (void)willDismissScreen:(id)view;


// 当用户点击了广告控件时，将要跳转到其它页面而触发的事件, 'view' 广告控件 'toWhere'广告推广方式:比如打开网站，跳转到App store.

- (void)onClicked:(id)view toWhere:(NSString*)toWhere;


@end


@interface MaxMobInterstitialAdView : UIView
@property (nonatomic) BOOL isReadly;
@property (nonatomic, assign) id <MaxMobInterstitialAdControllerDelegate> delegate;
@property (nonatomic, assign)UIViewController *controller;
-(id)initInterstitialAd:(NSString*) publishID  placement:(NSString*) placementID delegate:(id<MaxMobInterstitialAdControllerDelegate>)delegate;

-(void)loadInterstitialAd:(UIViewController*)controller;

-(void)showInterstitialAdvView;

@end

