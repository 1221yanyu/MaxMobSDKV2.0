//
//  MaxMobInterstitialAdViewController.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/13.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "MaxMobInterstitialAdView.h"
#import "MaxMobBase64.h"
#import "AdType.h"
#import "MaxMobAdViewManager.h"

@interface MaxMobInterstitialAdView ()
{
    MaxMobAdViewManager *maxmobAdViewManager;
    NSString* userKey;

}
@end

@implementation MaxMobInterstitialAdView
@synthesize delegate = _mminterstitialDelegate;
@synthesize controller = _mmcontroller;
BOOL isiPad;
float _logowidth;


//-(void)dealloc
//{
//    self.userKey = nil;
//    self.isReadly = nil;
//    [maxmobAdViewManager release];
//    maxmobAdViewManager = nil;
//    maxmobAdViewManager.delegate = nil;
//    maxmobAdViewManager.maxmobAdSDKView = nil;
//    maxmobAdViewManager.maxmobInterstitialAdView = nil;
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
            [_mminterstitialDelegate didAdReceived:nil withStatus:ErrorOfWrongID];
//            [userString release];
            return NO;
        }
    }
    typeOfAdSpace = [[userArray objectAtIndex:3] intValue];
    if(self)
    {
        userKey = userString;
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
//init interstitialAdView
-(id)initInterstitialAd:(NSString *)publishID placement:(NSString *)placementID delegate:(id<MaxMobInterstitialAdControllerDelegate>)delegate
{
    CGRect rect;
    rect = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    self = [super initWithFrame:rect];
    self.isReadly = NO;
    _mminterstitialDelegate = delegate;
    if (_mminterstitialDelegate != nil) {
        if (publishID) {
            if (placementID) {
                BOOL isVaildID = [self checkAppID:publishID checkPlacementID:placementID];
                if(isVaildID)
                {
                    return self;
                }
            }
        }
    }else
    {
        NSLog(@"Delegate must not be nil");
    }
    return nil;
}

-(void)loadInterstitialAd:(UIViewController *)controller
{
    BOOL hasSomeSEL = [controller respondsToSelector:@selector(presentModalViewController:animated:)];
    if (_mminterstitialDelegate == nil) {
        NSLog(@"Delegate must not be nil");
    }
    if (hasSomeSEL) {
        maxmobAdViewManager = [[MaxMobAdViewManager alloc] init];
        _mmcontroller = controller;
        maxmobAdViewManager.controller = _mmcontroller;
        maxmobAdViewManager.delegate = _mminterstitialDelegate;
        maxmobAdViewManager.userKey = userKey;
        maxmobAdViewManager.maxmobAdSDKView = self;
        maxmobAdViewManager.maxmobInterstitialAdView = self;
        maxmobAdViewManager.isCache = NO;
        maxmobAdViewManager.isiPad = isiPad;
        [maxmobAdViewManager prepareRequset];
        [_mmcontroller.view addSubview:self];

//         self.isReadly = maxmobAdViewManager.instlAdIsPrepare;
    }else
    {
        [_mminterstitialDelegate didAdReceived:nil withStatus:ErrorOfNilController];
    }
}
-(void)showInterstitialAdvView
{
//    self.isReadly = maxmobAdViewManager.instlAdIsPrepare;
    [maxmobAdViewManager clickShowInstlAd];
}

@end
