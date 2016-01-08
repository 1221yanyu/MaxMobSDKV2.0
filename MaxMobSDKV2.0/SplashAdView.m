//
//  SplashAdView.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/6/2.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "SplashAdView.h"

@implementation SplashAdView

extern int scale;
//-(void)dealloc
//{
//    [super dealloc];
//}

-(void)initInstanceVariable
{
    imageData = nil;
    logoView = nil;
    imgView = nil;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [ super initWithFrame:frame];
    
    if (self != nil) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        //        imgView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:imgView];
//        [imgView release];
        return self;
    }
    
    return nil;
}

- (NSData*)getImageData{
    return imageData;
}

-(void)setDataOfImage: (NSData*)dataOfImage
{
    imageData = dataOfImage;
}

-(void)setLogoAndJumpType:(NSDictionary *)json
{
    
}

-(void)setImg
{
    UIImage *img = [UIImage imageWithData:[self getImageData]];
    
    [imgView setImage:img];
    //    [imgView setContentMode:UIViewContentModeScaleAspectFit];
}

@end
