//
//  MaxMobSDKV1.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/8.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "MaxMobAdSDKView.h"
#import "MaxMobBase64.h"
#import "AdType.h"
#import "MaxMobAdViewManager.h"


@interface MaxMobAdSDKView ()
{
    MaxMobAdViewManager * adViewManager;
    NSString* userKey;
}
@end
@implementation MaxMobAdSDKView
@synthesize delegate = _mmAdViewDelegate;
@synthesize controller = _maxmobController;


BOOL isiPad;
float _logowidth;
//- (void)dealloc
//{
//    self.userKey = nil;
//    
//    [adViewManager release];
//    [super dealloc];
//}

- (BOOL)compareSize:(CGSize)size1 andSize:(CGSize)size2
{
    if ((size1.width == size2.width) && (size1.height == size2.height)) {
        return YES;
    }
    return NO;
}

- (BOOL)setTypeOfAdSpace:(TypeOfAd)typeOfAdSpace withFrame:(CGRect)frame
{
    isiPad = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        isiPad = NO;
        _logowidth = 20;
    } else {
        isiPad = YES;
        _logowidth = 40;
    }
    
    switch (typeOfAdSpace) {
        case BannerAd:
        {
            CGSize iPhoneBannerSize = CGSizeMake(320, 50);
            CGSize iPadBannerSize = CGSizeMake(768, 100);
            
            if (isiPad) {// iPad
                if (![self compareSize:frame.size andSize:iPadBannerSize] && ![self compareSize:frame.size andSize:iPhoneBannerSize]) {
                    NSLog(@"error");
                    MaxMobcatchErrors([self class], @"Set the ad view frame not correct, please correct it! The current device is iPad, so the ad view frame size is suggested (768,100) or (320,50)!");
                    [_mmAdViewDelegate didAdReceived:nil withStatus:ErrorOfWrongViewSize];
                    return NO;
                }
            } else { //iPhone
                if (![self compareSize:frame.size andSize:iPhoneBannerSize]) {
                    MaxMobcatchErrors([self class], @"Set the ad view frame not correct, please correct it! The current device is iPhone, so the ad view frame size is suggested (320,50)!");
                    [_mmAdViewDelegate didAdReceived:nil withStatus:ErrorOfWrongViewSize];
                    return NO;
                }
            }
            return YES;
        }
            break;
        case InterstitialAd:
            break;
        case SplashAd:
            break;
            
        default:
            break;
    }
    return YES;
}


//验证是否是纯数字
- (BOOL)isPureInt:(NSString*)string{
    
    NSScanner*scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return[scan scanInt:&val] && [scan isAtEnd];
}

//验证ID是否有效
-(BOOL)checkAppID:(NSString*)appID checkPlacementID:(NSString*)placementID frame:(CGRect)frame
{
    NSData* userData = [MaxMobBase64 decode:placementID];
    NSString* userString = [[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding];
    NSArray* userArray = [userString componentsSeparatedByString:@"|"];
    int typeOfAdSpace = -1;
    //验证ID是否为数字
    for (NSString* string in userArray) {
        if (![self isPureInt:string]) {
            //返回错误信息给开发者
            [_mmAdViewDelegate didAdReceived:nil withStatus:ErrorOfWrongID];
//            [userString release];
            return NO;
        }
    }
    typeOfAdSpace = [[userArray objectAtIndex:3] intValue];
    if(self)
    {
        //根据typeOfAdSpace数值判断广告类型
        if (![self setTypeOfAdSpace:typeOfAdSpace withFrame:(CGRect)frame]) {
            return NO;
        }
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

// init AdView
-(id)initAd:(NSString*) appID  placement:(NSString*) placementID   position:(CGRect)frame   delegate:(id<MaxMobAdSDKViewDelegate>)delegate
{
    self = [self initWithFrame:frame];
    _mmAdViewDelegate = delegate;
    if (_mmAdViewDelegate != nil) {
        if (appID) {
            if (placementID){
                BOOL isValidID= [self checkAppID:appID checkPlacementID:placementID frame:frame];
                if (isValidID)
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

// load AdView
-(void)loadAd:(UIViewController *)controller
{
    BOOL hasSomeSEL = [controller respondsToSelector:@selector(presentModalViewController:animated:)];
    if (_mmAdViewDelegate == nil) {
        NSLog(@"Delegate must not be nil");
    }
    if (hasSomeSEL) {
        adViewManager = [[MaxMobAdViewManager alloc] init];
        _maxmobController = controller;
        adViewManager.controller = _maxmobController;
        adViewManager.delegate = _mmAdViewDelegate;
        adViewManager.userKey = userKey;
        adViewManager.maxmobAdSDKView = self;
        adViewManager.isCache = NO;
        adViewManager.isiPad = isiPad;
        [adViewManager prepareRequset];
    }else
    {
        [_mmAdViewDelegate didAdReceived:nil withStatus:ErrorOfNilController];
    }
}
//
-(void)removeFromSuperview{
    
    [adViewManager stop];
    [super removeFromSuperview];
}
@end
