//
//  MaxMobNativeAd.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/8/18.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MaxMobAdViewManager;
@interface NativeAdData : NSObject

@property (nonatomic, strong) NSString *adTitle;
@property (nonatomic, strong) NSString *adBrief;
@property (nonatomic, strong) NSString *adDescripting;
@property (nonatomic, strong) NSString *adActionText;
@property (nonatomic, strong) NSString *adIcon;
@property (nonatomic, strong) NSString *adMedia;
@property (nonatomic, strong) NSString *mediaHeight;
@property (nonatomic, strong) NSString *mediaWidth;

@end
@protocol MaxMobNativeDelegate <NSObject>

- (void)didAdReceived:(id)view withStatus:(NSString*)resultStatus;
- (void)maxmobNativeAdLoadSuccess:(NativeAdData *)adDataModel;
- (void)maxmobNAtiveAdViewWithStyleLoadSuccess:(UIView *)adViewWithStyle;
@end

@interface MaxMobNativeAd : NSObject

@property (nonatomic,assign) NativeAdData *nativeAdData;

@property (nonatomic, assign) id<MaxMobNativeDelegate> delegate;
@property (nonatomic, retain)NSString* userKey;
-(id)initWithPublishId:(NSString *)publishId
           placementId:(NSString *)placementId
    rootViewController:(UIViewController *)rootViewController
              delegate:(id<MaxMobNativeDelegate>)delegate;
-(id)initWithPublishId:(NSString *)publishId
           placementId:(NSString *)placementId
                 style:(NSString *)style
    rootViewController:(UIViewController *)rootViewController
              delegate:(id<MaxMobNativeDelegate>)delegate;
-(void)loadAd;
-(void)loadAdWithStyle;
-(void)clickAd;
@end