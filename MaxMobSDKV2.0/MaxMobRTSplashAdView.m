//
//  MaxMobRTSplashAdView.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/6/9.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "MaxMobRTSplashAdView.h"
#import "MaxMobBase64.h"
#import "AdType.h"
#import "MaxMobAdViewManager.h"

@interface MaxMobRTSplashAdView ()
{
    MaxMobAdViewManager *maxmobAdViewManager;
}

@end
@implementation MaxMobRTSplashAdView
@synthesize delegate = _mminterstitialDelegate;
@synthesize controller = _mmcontroller;
@synthesize userKey = _mmuserKey;
@synthesize isReady = _mmisReady;

//-(void)dealloc
//{
//    self.userKey = nil;
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
    NSData* userData = [MaxMobBase64 decode:appID];
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

//init splashAdView
-(id)initSplashAd:(NSString *)appID placement:(NSString *)placementID orientation:(NSString *)orientationStatus window:(UIWindow*)window background:(UIColor *)background delegate:(id<MaxMobRTSplashAdControllerDelegate>)delegate
{
    CGRect rect;
    rect = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    self = [super initWithFrame:rect];
    
//    _mminterstitialDelegate = [delegate retain];
    if (_mminterstitialDelegate != nil) {
        if (appID) {
            if (placementID) {
                BOOL isVaildID = [self checkAppID:appID checkPlacementID:placementID];
                if(isVaildID)
                {
                    [window setBackgroundColor:background];
                    [self loadSplashlAd:orientationStatus window:window];
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
-(void)loadSplashlAd:(NSString *)orientationStatus  window:(UIWindow*)window
{
//    self.hidden = YES;
    [window addSubview:self];

    maxmobAdViewManager = [[MaxMobAdViewManager alloc] init];
    maxmobAdViewManager.delegate = _mminterstitialDelegate;
    maxmobAdViewManager.userKey = _mmuserKey;
    maxmobAdViewManager.maxmobAdSDKView = self;
    maxmobAdViewManager.isCache = YES;
    maxmobAdViewManager.isRTSplash = YES;
    maxmobAdViewManager.orientationStatus = orientationStatus;
    [maxmobAdViewManager prepareRequset];
}

-(void)showRTSplashAd{
    [maxmobAdViewManager showRTSplashAd];
}
@end
