//
//  AdType.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/13.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface AdType : NSObject
@end
//广告类型
#define BannerAdType                            @"1"
//#define RimgAdType                              @"rimg"
#define InterstitialAdType                      @"2"
#define SplashAdType                            @"3"
#define NativeAdType                            @"20"
typedef enum {
    BannerAd = 1,
    InterstitialAd =2,
    SplashAd = 3,
    NativeAd = 4,
    
}TypeOfAd;