//
//  ViewController.h
//  testAd
//
//  Created by Jacob on 15/12/10.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaxMobAdSDKView.h"


@interface BannerViewController : UIViewController < MaxMobAdSDKViewDelegate>
{
    MaxMobAdSDKView *maxmobAdView;
}

@end

