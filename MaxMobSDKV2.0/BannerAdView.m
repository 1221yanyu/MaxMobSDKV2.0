//
//  BannerAdView.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/27.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "BannerAdView.h"

@implementation BannerAdView 

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

-(void)setImg:(NSDictionary *)json
{
    if ([MaxMobJsonDicAnalysis imageStringIsGif:[MaxMobJsonDicAnalysis getImageLinkString:json]]) {
        UIImage *img = [UIImage imageWithData:[self getImageData]];
        [imgView setImage:img];
    }else
    {
        UIImage *img = [UIImage imageWithData:[self getImageData]];   [imgView setImage:img];
    }
}


@end
