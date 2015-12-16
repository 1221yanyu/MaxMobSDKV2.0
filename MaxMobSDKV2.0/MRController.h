//
//  MRController.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/4.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MRConstants.h"

@protocol MRControllerDelegate;
@class MMAdConfiguration;
@class CLLocation;

@interface MRController : NSObject

@property (nonatomic, assign) id<MRControllerDelegate> delegate;

-(instancetype)initWithAdViewFrame:(CGRect)adViewFrame adPlacementType:(MRAdViewPlacementType)placementType;

-(void)loadAdWithConfiguration:(MMAdConfiguration *)configuration;
//-(void)handleMRAIDInterstitialDidPresentWithViewController:()
-(void)enableRequestHandling;
-(void)disableRequestHanding;

@end

@protocol MRControllerDelegate <NSObject>

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