//
//  Advertisement.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/13.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdAction.h"
#import "AdType.h"
#import "Transition.h"
#import "MaxMobAdViewManager.h"
#import "LocalCache.h"
#import "BannerAdView.h"
#import "InterstitialAdView.h"
#import "SplashAdView.h"
#import "MRControllerNew.h"
//跳转类型
#define MARKET                                   @"2"
#define WEB                                      @"1"
@interface Advertisement : NSObject <MRControllerNewDelegate> //广告类
{
    
    MRControllerNew *mrController;
    
    NSInteger adid;     //广告id
    NSString* adname;   //广告名称
    AdType* type;       //广告类型
    NSInteger height;   //广告高度尺寸
    NSInteger width;    //广告宽度尺寸
    NSString* picture;  //广告图片URL
    NSString* video;    //广告视频URL
    NSString* logo;     //广告logoURL
    NSString* jumpurl;  //广告点击跳转URL
    NSString* method;   //广告推广方式（网页、下载）
    NSString* adfclick; //上报地址
    NSInteger refresh;  //自动刷新时间

    
//    NSString *networkStatus;
//    UIView *adToShow;
//    NSString *documentDir;
//    NSString *adToShowJumpLink;
//    NSString *adToShowLinkType;

    Transition* transition;
}
@property (nonatomic, assign) NSString *networkStatus;
@property (nonatomic, retain) UIView *adToShow;
@property (nonatomic, retain)NSString *documentDir;         //文件目录
@property (nonatomic, retain)NSString *adToShowJumpLink;
@property (nonatomic, retain)NSString *adToShowLinkType;
-(id)useLocalCache:(NSString*)linkString json:(NSDictionary*)json ;
-(BOOL)prepareMrBannerAd:(NSDictionary *)json frame:(CGRect)frame;
-(BOOL)prepareBannerAd:(NSDictionary *)json ctrlFrame:(CGRect)cframe Cache:(BOOL)isCache entype:(NSStringEncoding)entype;
-(BOOL)prepareInterstitialAd:(NSDictionary *)json ctrlFrame:(CGRect)cframe Cache:(BOOL)isCache entype:(NSStringEncoding)entype;
-(BOOL)prepareSplashAd:(NSDictionary *)json ctrlFrame:(CGRect)cframe Cache:(BOOL)isCache entype:(NSStringEncoding)entype;

//-(void)initAd;
//
//-(id)SetAdTypeWithTypeString:(NSString *)_AdType;
//-(NSInteger)setHeigetWithString:(NSString*)_Height;
//-(NSInteger)setWidthWithString:(NSString*)_Width;
//-(NSInteger)setRefreshWithString:(NSString*)_Refresh;

@end

