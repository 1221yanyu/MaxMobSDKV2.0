//
//  RichMediaBannerViewController.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 16/1/7.
//  Copyright © 2016年 Jacob. All rights reserved.
//

#import "RichMediaBannerViewController.h"
#import "MRBridge.h"

@implementation RichMediaBannerViewController

-(void)viewDidLoad
{
    NSString *PublishID = @"M3xudWxsfDB8MA==";
    NSString *PlacementID = @"MTB8M3wzOHwx";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        maxmobAdView = [[MaxMobAdSDKView alloc] initAd:PublishID placement:PlacementID position: CGRectMake(0, 100, 320, 50 ) delegate:self];
    } else {
        maxmobAdView = [[MaxMobAdSDKView alloc] initAd:PublishID placement:PlacementID position: CGRectMake(0, 100, 768, 100) delegate:self];
    }
    [maxmobAdView loadAd:self];//adview instance begin to request ad.
    [self.view addSubview:maxmobAdView];
}


- (void)didAdReceived:(id)view withStatus:(NSString*)resultStatus{//when finished requesting a ad, then callback this method, return status.
    NSLog(@"result status is: %@", resultStatus);
}

- (void)onClicked:(id)view toWhere:(NSString *)toWhere{//when user clicked the view, then callback this method, 'toWhere' means the
    NSLog(@"toWhere is: %@", toWhere);
}

- (void)willDismissScreen:(id)view{//when user clicked the done button from webview, then callback this method.
    NSLog(@"Come back to ad view.");
}



//#pragma mark - MRControllerDelegate
//
//-(NSString *)adUnitId{
//    return nil;
//}
//-(MMAdConfiguration *)adConfiguration{
//    return nil;
//}
//-(CLLocation *)location{
//    return nil;
//}
//
//
//-(UIViewController *)viewControllerForPresentingModalView{
//    
//    return nil;
//}
//
//-(void)appShouldSuspendForAd:(UIView *)adView{
//    
//}
//
//-(void)appShouldResumeFromAd:(UIView *)adView{
//    
//}
//
//-(void)adDidLoad:(UIView *)adView{
//    [self.view addSubview:adView];
//    //    mrController.delegate = nil;
//}
//
//-(void)adDidFailToLoad:(UIView *)adView{
//    
//}
//
//-(void)adWillClose:(UIView *)adView{
//    
//}
//
//-(void)adDidClose:(UIView *)adView{
//    
//}



@end
