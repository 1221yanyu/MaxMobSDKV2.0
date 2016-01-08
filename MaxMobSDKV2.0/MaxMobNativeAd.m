//
//  MaxMobNativeAd.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/8/18.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "MaxMobNativeAd.h"
#import "MaxMobAdViewManager.h"



@implementation NativeAdData
@synthesize adTitle = _adTitle;
@synthesize adBrief = _adBrief;
@synthesize adActionText = _adActionText;
@synthesize adIcon = _adIcon;
@synthesize adMedia = _adMedia;
@synthesize mediaHeight = _mediaHeight;
@synthesize mediaWidth = _mediaWidth;
@end
@interface MaxMobNativeAd ()
{
    MaxMobAdViewManager *maxmobAdViewManager;
    UIViewController * mmViewController;
    NSString *adStyle;
}

@end
@implementation MaxMobNativeAd

@synthesize delegate = _mmNativedelegate;
@synthesize userKey = _mmuserKey;
//-(void)dealloc
//{
//    [maxmobAdViewManager release];
//    [super dealloc];
//}
//验证是否是纯数字
- (BOOL)isPureInt:(NSString*)string{
    
    NSScanner*scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return[scan scanInt:&val] && [scan isAtEnd];
}
//验证ID是否有效
-(BOOL)checkAppID:(NSString*)appID checkPlacementID:(NSString*)placementID
{
    NSData* userData = [MaxMobBase64 decode:placementID];
    NSString* userString = [[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding];
    NSArray* userArray = [userString componentsSeparatedByString:@"|"];
    int typeOfAdSpace = -1;
    //验证ID是否为数字
    for (NSString* string in userArray) {
        if (![self isPureInt:string]) {
            //返回错误信息给开发者
            [_mmNativedelegate didAdReceived:nil withStatus:ErrorOfWrongID];
//            [userString release];
            return NO;
        }
    }
    typeOfAdSpace = [[userArray objectAtIndex:3] intValue];
    if(self)
    {
        self.userKey = userString;
//        [userString release];
        userArray = nil;
        return YES;
    }else
    {
//        [userString release];
        userArray = nil;
        return NO;
    }
}
-(id)initWithPublishId:(NSString *)publishId placementId:(NSString *)placementId rootViewController:(UIViewController *)rootViewController delegate:(id<MaxMobNativeDelegate>)delegate
{
//    _mmNativedelegate = [delegate retain];
    mmViewController = rootViewController;
    if (_mmNativedelegate != nil) {
        if (publishId) {
            if (placementId) {
                BOOL isVaildID = [self checkAppID:publishId checkPlacementID:placementId];
                if (isVaildID) {
                    return self;
                }
            }
        }
    }
    return nil;
}
-(id)initWithPublishId:(NSString *)publishId placementId:(NSString *)placementId style:(NSString *)style rootViewController:(UIViewController *)rootViewController delegate:(id<MaxMobNativeDelegate>)delegate
{
//    _mmNativedelegate = [delegate retain];
    mmViewController = rootViewController;
    adStyle = style;
    if (_mmNativedelegate != nil) {
        if (publishId) {
            if (placementId) {
                BOOL isVaildID = [self checkAppID:publishId checkPlacementID:placementId];
                if (isVaildID) {
                    return self;
                }
            }
        }
    }
    return nil;
}
-(void)loadAd {
    maxmobAdViewManager = [[MaxMobAdViewManager alloc] init];
    maxmobAdViewManager.nativeDelegate = _mmNativedelegate;
    maxmobAdViewManager.userKey = _mmuserKey;

    maxmobAdViewManager.nativeViewController = mmViewController;
    maxmobAdViewManager.isCache = NO;
    [maxmobAdViewManager prepareNativeRequset];
    
    
}
-(void)loadAdWithStyle {
    maxmobAdViewManager = [[MaxMobAdViewManager alloc] init];
    maxmobAdViewManager.nativeDelegate = _mmNativedelegate;
    maxmobAdViewManager.userKey = _mmuserKey;
    maxmobAdViewManager.adStyle = adStyle;
    maxmobAdViewManager.maxmobAdSDKView = mmViewController;
    maxmobAdViewManager.isCache = NO;
    [maxmobAdViewManager prepareNativeRequsetWithStyle:adStyle];
    [maxmobAdViewManager prepareRequset];
    
}
-(void)clickAd{
    [maxmobAdViewManager nativeAdClick];
}
@end
