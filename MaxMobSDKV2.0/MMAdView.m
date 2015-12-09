//
//  MMAdView.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/9.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MMAdView.h"
#import "MMBannerAdManager.h"
@interface MMAdView ()

@property (nonatomic, strong) MMBannerAdManager *adManager;
@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, weak) UIView *adContentView;

@end

@implementation MMAdView

@synthesize delegate = _delegate;

-(id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size
{
    CGRect f = (CGRect){{0 , 0}, size};
    if (self = [super initWithFrame:f]) {
        self.backgroundColor = [UIColor clearColor];
        self.originalSize = size;
    }
    return self;
}

-(void)dealloc
{
    
}

-(void)setAdContentView:(UIView *)view
{
    [self.adContentView removeFromSuperview];
    _adContentView = view;
    [self addSubview:view];
}

-(CGSize)adContentViewSize
{
    return self.adContentView.bounds.size;
}

-(void)loadAd
{
 
}
@end
