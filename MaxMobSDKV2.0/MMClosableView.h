//
//  MRCloseableView.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/10.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    MMClosableViewCloseButtonLocationTopRight,
    MMClosableViewCloseButtonLocationTopLeft,
    MMClosableViewCloseButtonLocationTopCenter,
    MMClosableViewCloseButtonLocationBottomRight,
    MMClosableViewCloseButtonLocationBottomLeft,
    MMClosableViewCloseButtonLocationBottomCenter,
    MMClosableViewCloseButtonLocationCenter
};
typedef NSInteger MMClosableViewCloseButtonLocation;

enum {
    MMClosableViewCloseButtonTypeNone,
    MMClosableViewCloseButtonTypeTappableWithoutImage,
    MMClosableViewCloseButtonTypeTappableWithImage,
};
typedef NSInteger MMClosableViewCloseButtonType;

CGRect MMClosableViewCustomCloseButtonFrame(CGSize size, MMClosableViewCloseButtonLocation closeButtonLocation);

@protocol MMClosableViewDelegate;

@interface MMClosableView : UIView

@property (nonatomic, weak) id<MMClosableViewDelegate> delegate;
@property (nonatomic, assign) MMClosableViewCloseButtonType closeButtonType;
@property (nonatomic, assign) MMClosableViewCloseButtonLocation closeButtonLocation;
@property (nonatomic, readonly) BOOL wasTapped;

- (instancetype)initWithFrame:(CGRect)frame closeButtonType:(MMClosableViewCloseButtonType)closeButtonType;

@end


@protocol MMClosableViewDelegate <NSObject>

- (void)closeButtonPressed:(MMClosableView *)closableView;

@optional

- (void)closableView:(MMClosableView *)closableView didMoveToWindow:(UIWindow *)window;

@end
