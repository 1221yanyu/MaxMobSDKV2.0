//
//  MMAdView.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/9.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMAdViewDelegate;

@interface MMAdView : UIView

-(id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size;

@property (nonatomic, weak) id<MMAdViewDelegate> delegate;

-(void)loadAd;


@end

@protocol MMAdViewDelegate <NSObject>

@required

-(UIViewController *)viewControllerForPersentingModalView;

@optional

-(void)adViewDidLoadAd:(MMAdView *)view;

-(void)adViewDidFailToLoadAd:(MMAdView *)view;

@end