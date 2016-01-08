//
//  MaxMobSDKV1.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/8.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MaxMobAdViewManager;

@protocol MaxMobAdSDKViewDelegate <NSObject>

//请求广告结果返回触发事件,  'view' 广告控件 'resultStatus'返回结果状态

- (void)didAdReceived:(id)view withStatus:(NSString*)resultStatus;


// 当用户点击了'Done'按键时，将要返回到广告控件的view, 'view' 广告控件

- (void)willDismissScreen:(id)view;


// 当用户点击了广告控件时，将要跳转到其它页面而触发的事件, 'view' 广告控件 'toWhere'广告推广方式:比如打开网站，跳转到App store.

- (void)onClicked:(id)view toWhere:(NSString*)toWhere;


@end

@interface MaxMobAdSDKView : UIView

@property (nonatomic, assign) id <MaxMobAdSDKViewDelegate> delegate;
@property (nonatomic, assign)UIViewController *controller;

// init AdView
-(id)initAd:(NSString*) appID  placement:(NSString*) placementID position:(CGRect)frame delegate:(id<MaxMobAdSDKViewDelegate>)delegate;

// load AdView
-(void)loadAd:(UIViewController*)controller;

@end




