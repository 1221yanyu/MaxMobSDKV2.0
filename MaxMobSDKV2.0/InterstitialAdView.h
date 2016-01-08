//
//  InterstitialAdView.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/5/28.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaxMobJsonDicAnalysis.h"
#import "MaxMobBase64.h"
@interface InterstitialAdView : UIView
{
    NSData *imageData;
    UIImageView *logoView;
    UIImageView *imgView;
    UIButton *closeBtn;
}

-(void)setDataOfImage: (NSData*)dataOfImage;

-(void)setLogoAndJumpType:(NSDictionary *)json;

-(void)setImg:(NSDictionary *)json;
@end
