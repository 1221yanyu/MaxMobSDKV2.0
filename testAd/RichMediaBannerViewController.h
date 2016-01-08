//
//  RichMediaBannerViewController.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 16/1/7.
//  Copyright © 2016年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaxMobAdSDKView.h"
@interface RichMediaBannerViewController : UIViewController <MaxMobAdSDKViewDelegate>
{
    MaxMobAdSDKView *maxmobAdView;
}

@end
