//
//  MMAdConfiguration.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/7.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
    MMAdTypeUnknown = -1,
    MMAdTypeBanner = 0,
    MMAdTypeInterstitial = 1
};
typedef NSUInteger MMAdType;

@interface MMAdConfiguration : NSObject

@property (nonatomic, assign) MMAdType adType;
@property (nonatomic, assign) BOOL adUnitWarmingUp;
@property (nonatomic, copy) NSString *networkType;
@property (nonatomic, assign) CGSize preferredSize;
@property (nonatomic, strong) NSURL *clickTrackingURL;
@property (nonatomic, strong) NSURL *impressionTrackingURL;
@property (nonatomic, strong) NSURL *failoverURL;
@property (nonatomic, strong) NSURL *interceptURLPrefix;
@property (nonatomic, assign) BOOL shouldInterceptLinks;
@property (nonatomic, assign) BOOL scrollable;
@property (nonatomic, assign) NSTimeInterval refreshInterval;
@property (nonatomic, assign) NSTimeInterval adTimeoutInterval;
@property (nonatomic, copy) NSData *adResponseData;
@property (nonatomic, strong) NSDictionary *nativeSDKParameters;
@property (nonatomic, copy) NSString *customSelectorName;
@property (nonatomic, assign) Class customEventClass;
@property (nonatomic, strong) NSDictionary *customEventClassData;
//@property (nonatomic, assign) MPInterstitialOrientationType orientationType;
@property (nonatomic, copy) NSString *dspCreativeId;
@property (nonatomic, assign) BOOL precacheRequired;
@property (nonatomic, assign) BOOL isVastVideoPlayer;
@property (nonatomic, strong) NSDate *creationTimestamp;
@property (nonatomic, copy) NSString *creativeId;
@property (nonatomic, copy) NSString *headerAdType;
@property (nonatomic, assign) NSInteger nativeVideoPlayVisiblePercent;
@property (nonatomic, assign) NSInteger nativeVideoPauseVisiblePercent;
@property (nonatomic, assign) NSInteger nativeVideoImpressionMinVisiblePercent;
@property (nonatomic, assign) NSTimeInterval nativeVideoImpressionVisible;
@property (nonatomic, assign) NSTimeInterval nativeVideoMaxBufferingTime;

- (id)initWithHeaders:(NSDictionary *)headers data:(NSData *)data;

- (BOOL)hasPreferredSize;
- (NSString *)adResponseHTMLString;
- (NSString *)clickDetectionURLPrefix;

@end
