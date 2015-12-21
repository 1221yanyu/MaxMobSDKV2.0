//
//  MRControllerNew.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/19.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MRConstants.h"

#define TestHTMLMopubBanner @"readAd"
#define TestHTMLExpand @"mraid_expand"


#define CommandExpand @"expand"
#define CommandSetOrientationProperties @"setOrientationProperties"
#define CommandClose @"close"

@protocol MRControllerNewDelegate;
@class MMAdConfiguration;
@class CLLocation;

@interface MRControllerNew : NSObject

@property (nonatomic, assign) id<MRControllerNewDelegate> delegate;

-(instancetype)initWithAdViewFrame:(CGRect)adViewFrame adPlacementType:(MRAdViewPlacementType)placementType;

-(void)loadAdWithConfiguration:(MMAdConfiguration *)configuration;
//-(void)handleMRAIDInterstitialDidPresentWithViewController:()
-(void)enableRequestHandling;
-(void)disableRequestHanding;

@end

@protocol MRControllerNewDelegate <NSObject>

@required

-(NSString *)adUnitId;
-(MMAdConfiguration *)adConfiguration;
-(CLLocation *)location;


-(UIViewController *)viewControllerForPresentingModalView;

-(void)appShouldSuspendForAd:(UIView *)adView;

-(void)appShouldResumeFromAd:(UIView *)adView;


@optional

-(void)adDidLoad:(UIView *)adView;

-(void)adDidFailToLoad:(UIView *)adView;

-(void)adWillClose:(UIView *)adView;

-(void)adDidClose:(UIView *)adView;

@end