//
//  InterstitialViewController.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 16/1/7.
//  Copyright © 2016年 Jacob. All rights reserved.
//

#import "InterstitialViewController.h"

@implementation InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *PublishID = @"N3w3fDE4fDI=";
    NSString *PlacementID = @"MTB8M3wyNHwy";
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        maxmobInterstitialAdView = [[MaxMobInterstitialAdView alloc] initInterstitialAd:PublishID placement:PlacementID delegate:self];
    }else
    {
        maxmobInterstitialAdView = [[MaxMobInterstitialAdView alloc] initInterstitialAd:PublishID placement:PlacementID delegate:self];
    }
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

- (IBAction)loadAd:(id)sender {
    NSLog(@"click Prepare");
    [maxmobInterstitialAdView loadInterstitialAd:self];
}

- (IBAction)showAd:(id)sender {
    NSLog(@"click show");
    [maxmobInterstitialAdView showInterstitialAdvView];
}
@end
