//
//  Advertisement.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/13.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "Advertisement.h"
@implementation Advertisement

@synthesize adToShow = _adToShow;
@synthesize adToShowJumpLink = _adToShowJumpLink;
@synthesize adToShowLinkType = _adToShowLinkType;
@synthesize documentDir;
@synthesize networkStatus;
-(id)init
{
    self = [super init];
    return self;
}
//创建mraidBanner
-(void)creatMrBannerAdViewWithFrame:(CGRect)frame json:(NSDictionary *)json
{
    mrController = [[MRControllerNew alloc]initWithAdViewFrame:frame adPlacementType:MRAdViewPlacementTypeInline];
    mrController.delegate = self;
    NSString *html = [MaxMobJsonDicAnalysis getHTMLLinkString:json];
    [mrController loadAdWithHTML:html];
}
-(void)adDidLoad:(UIView *)adView
{
    _adToShow = adView;
}
-(BOOL)prepareMrBannerAd:(NSDictionary *)json frame:(CGRect)frame entype:(NSStringEncoding)entype
{
    [self creatMrBannerAdViewWithFrame:frame json:json];
    //判断跳转类型
    NSString *linkString = [MaxMobJsonDicAnalysis getLinkString:json];
    
    _adToShowLinkType = [[NSMutableString alloc] initWithString:[MaxMobJsonDicAnalysis getLinkType:json]];
    if (!_adToShowLinkType) {
        //        [bannerAdView release];
        return NO;
    }
    AdAction *adAction;
    adAction = [[AdAction alloc]init];
    [adAction checkAdToShowLinkType:_adToShowLinkType linkStr:linkString json:json entype:entype];
    _adToShowJumpLink =adAction.adToShowJumpLink;
    if (_adToShow) {
        //        [_adToShow release];
    }
    //    [bannerAdView release];
    return YES;
}

-(BOOL)prepareBannerAd:(NSDictionary *)json ctrlFrame:(CGRect)cframe Cache:(BOOL)isCache entype:(NSStringEncoding)entype
{
    id dataOfImgView = nil;
    isCache = NO;
    if (isCache) {//开启缓存时，先使用缓存
        NSString *linkOfImg = [MaxMobJsonDicAnalysis getImageLinkString:json];
        if (!linkOfImg)
        {
            return NO;
        }else
        {
            dataOfImgView = [self  useLocalCache:linkOfImg json:json];
            if(!dataOfImgView)
            {
                return NO;
            }
        }
    }else
    {
        NSString *linkOfImg = [MaxMobJsonDicAnalysis getImageLinkString:json];
        if (!linkOfImg) {
            return NO;
        } else {
            if ( [networkStatus isEqualToString: @"yes"]) {
                dataOfImgView = [MaxMobAdViewManager sendURL:linkOfImg];
            }
            if (!dataOfImgView) {
                return NO;
            }
        }
    }
    //调用BannerADView
    BannerAdView *bannerAdView = [[BannerAdView alloc] initWithFrame:cframe];
    [bannerAdView setDataOfImage:dataOfImgView];
    NSString *isLogo = [MaxMobJsonDicAnalysis getLogoString:json];
    if (isLogo.length) {
        [bannerAdView setLogoAndJumpType:json];
    }
    [bannerAdView setImg:json];
    //判断跳转类型
    NSString *linkString = [MaxMobJsonDicAnalysis getLinkString:json];

    _adToShowLinkType = [[NSMutableString alloc] initWithString:[MaxMobJsonDicAnalysis getLinkType:json]];
    if (!_adToShowLinkType) {
//        [bannerAdView release];
        return NO;
    }
    AdAction *adAction;
    adAction = [[AdAction alloc]init];
    if (![adAction checkAdToShowLinkType:_adToShowLinkType linkStr:linkString json:json entype:entype])
    {
//        [bannerAdView release];
        bannerAdView = nil;
        return NO;
    }
    _adToShowJumpLink =adAction.adToShowJumpLink;
    if (_adToShow) {
//        [_adToShow release];
    }
    _adToShow = bannerAdView;
//    [bannerAdView release];
    return YES;
}

-(BOOL)prepareInterstitialAd:(NSDictionary *)json ctrlFrame:(CGRect)cframe Cache:(BOOL)isCache entype:(NSStringEncoding)entype
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        cframe.size.width = 300;
        cframe.size.height = 250;
        cframe.origin.x = [UIScreen mainScreen].bounds.size.width-300;
        cframe.origin.x = cframe.origin.x/2;
        cframe.origin.y = [UIScreen mainScreen].bounds.size.height-250;
        cframe.origin.y = cframe.origin.y/2;
    }else
    {
        cframe.size.width = 600;
        cframe.size.height = 500;
        cframe.origin.x = [UIScreen mainScreen].bounds.size.width-600;
        cframe.origin.x = cframe.origin.x/2;
        cframe.origin.y = [UIScreen mainScreen].bounds.size.height-500;
        cframe.origin.y = cframe.origin.y/2;
    }
    id dataOfImgView = nil;
    if (isCache) {//开启缓存时，先使用缓存
        NSString *linkOfImg = [MaxMobJsonDicAnalysis getImageLinkString:json];
        if (!linkOfImg)
        {
            return NO;
        }else
        {
            dataOfImgView = [self  useLocalCache:linkOfImg json:json];
            if(!dataOfImgView)
            {
                return NO;
            }
        }
    }else
    {
        NSString *linkOfImg = [MaxMobJsonDicAnalysis getImageLinkString:json];
        if (!linkOfImg) {
            return NO;
        } else {
            if ( [networkStatus isEqualToString: @"yes"]) {
                dataOfImgView = [MaxMobAdViewManager sendURL:linkOfImg];
            }
            if (!dataOfImgView) {
                return NO;
            }
        }
    }
   
    //调用InterstitialAd
    InterstitialAdView *interstitialAd = [[InterstitialAdView alloc] initWithFrame:cframe];
    [interstitialAd setDataOfImage:dataOfImgView];
    [interstitialAd setImg:json];

    //判断跳转类型
    NSString *linkString = [MaxMobJsonDicAnalysis getLinkString:json];
    if (_adToShowLinkType) {
//        [_adToShowLinkType release];
    }
    _adToShowLinkType = [[NSMutableString alloc] initWithString:[MaxMobJsonDicAnalysis getLinkType:json]];
    if (!_adToShowLinkType) {
//        [interstitialAd release];
        return NO;
    }
    AdAction *adAction;
    adAction = [[AdAction alloc]init];
    if (![adAction checkAdToShowLinkType:_adToShowLinkType linkStr:linkString json:json entype:entype])
    {
//        [interstitialAd release];
        interstitialAd = nil;
        return NO;
    }
    _adToShowJumpLink =adAction.adToShowJumpLink;
    if (_adToShow) {
//        [_adToShow release];
    }
    _adToShow = interstitialAd;
//    [interstitialAd release];
    return YES;
}

-(BOOL)prepareSplashAd:(NSDictionary *)json ctrlFrame:(CGRect)cframe Cache:(BOOL)isCache entype:(NSStringEncoding)entype
{
    id dataOfImgView = nil;
    if (isCache) {//开启缓存时，先使用缓存
        NSString *linkOfImg = [MaxMobJsonDicAnalysis getImageLinkString:json];
        if (!linkOfImg)
        {
            return NO;
        }else
        {
            dataOfImgView = [self  useLocalCache:linkOfImg json:json];
            if(!dataOfImgView)
            {
                return NO;
            }
        }
    }else
    {
        NSString *linkOfImg = [MaxMobJsonDicAnalysis getImageLinkString:json];
        if (!linkOfImg) {
            return NO;
        } else {
            if ( [networkStatus isEqualToString: @"yes"]) {
                dataOfImgView = [MaxMobAdViewManager sendURL:linkOfImg];
            }
            if (!dataOfImgView) {
                return NO;
            }
        }
    }
    
    //调用SplashAd
    SplashAdView *splashAd = [[SplashAdView alloc] initWithFrame:cframe];
    [splashAd setDataOfImage:dataOfImgView];
    [splashAd setImg];
    
//    //判断跳转类型
//    NSString *linkString = [MaxMobJsonDicAnalysis getLinkString:json];
//    if (_adToShowLinkType) {
//        [_adToShowLinkType release];
//    }
//    _adToShowLinkType = [[NSMutableString alloc] initWithString:[MaxMobJsonDicAnalysis getLinkType:json]];
//    if (!_adToShowLinkType) {
//        [splashAd release];
//        return NO;
//    }
//    AdAction *adAction;
//    adAction = [[AdAction alloc]init];
//    if (![adAction checkAdToShowLinkType:_adToShowLinkType linkStr:linkString json:json entype:entype])
//    {
//        [splashAd release];
//        splashAd = nil;
//        return NO;
//    }
//    _adToShowJumpLink =adAction.adToShowJumpLink;
    if (_adToShow) {
//        [_adToShow release];
    }
    _adToShow = splashAd;
//    [splashAd release];
    return YES;
}

-(id)useLocalCache:(NSString*)linkString json:(NSDictionary*)json
{
    //判断本地图片是否已经存在
    BOOL isFileExist = NO;
    NSData *result = nil;
    //write to file
    NSMutableString *fileName = [[NSMutableString alloc]init];
    NSString *adType = [MaxMobJsonDicAnalysis getAdType:json];
    [fileName appendString:adType];
    [fileName appendFormat:@"_"];
    [fileName appendString:[MaxMobJsonDicAnalysis getAdId:json]];
    [fileName appendFormat:@".png"];
    LocalCache *localCache = [[LocalCache alloc] init];
    isFileExist = [localCache existFileAtDir:fileName];
    if (!isFileExist) {//if file not exists, need to request
        if ([networkStatus isEqualToString:@"yes"]) {
            result = [MaxMobAdViewManager sendURL:linkString];
            if (!result) {
//                [localCache release];
//                [fileName release];
                return nil;
            }
            if ([localCache willDeleteFile]) {
                [localCache deleteFile];
            }
            [result writeToFile:[documentDir stringByAppendingPathComponent:fileName] atomically:YES];
            
        }else{
            //等待30秒
//            [localCache release];
//            [fileName release];
            return nil;
        }
    }else{//exist on the local disk
        result = [localCache getFileContent];
    }
    
//    [fileName release];
//    [localCache release];
    return result;
}


@end
