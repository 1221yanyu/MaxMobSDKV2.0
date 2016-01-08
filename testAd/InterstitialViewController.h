//
//  InterstitialViewController.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 16/1/7.
//  Copyright © 2016年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaxMobInterstitialAdView.h"
@interface InterstitialViewController : UIViewController<MaxMobInterstitialAdControllerDelegate>
{
    MaxMobInterstitialAdView *maxmobInterstitialAdView;
}
- (IBAction)loadAd:(id)sender;
- (IBAction)showAd:(id)sender;

@end
