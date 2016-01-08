//
//  SplashAdView.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/6/2.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashAdView : UIView
{
    NSData *imageData;
    UIImageView *logoView;
    UIImageView *imgView;
    UIButton *closeBtn;
}
-(void)setDataOfImage: (NSData*)dataOfImage;

-(void)setLogoAndJumpType:(NSDictionary *)json;

-(void)setImg;
@end
