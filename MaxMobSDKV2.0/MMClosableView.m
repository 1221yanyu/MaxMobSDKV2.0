//
//  MRCloseableView.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/10.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MMClosableView.h"



static CGFloat kCloseRegionWidth = 50.0f;
static CGFloat kCloseRegionHeight = 50.0f;
static NSString *const kExpandableCloseButtonImageName = @"MMCloseButtonX.png";

CGRect MMClosableViewCustomCloseButtonFrame(CGSize size, MMClosableViewCloseButtonLocation closeButtonLocation)
{
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGRect closeButtonFrame = CGRectMake(0, 0, kCloseRegionWidth, kCloseRegionHeight);
    
    switch (closeButtonLocation) {
        case MMClosableViewCloseButtonLocationTopRight:
            closeButtonFrame.origin = CGPointMake(width-kCloseRegionWidth, 0.0f);
            break;
        case MMClosableViewCloseButtonLocationTopLeft:
            closeButtonFrame.origin = CGPointMake(0.0f, 0.0f);
            break;
        case MMClosableViewCloseButtonLocationTopCenter:
            closeButtonFrame.origin = CGPointMake((width-kCloseRegionWidth) / 2.0f, 0.0f);
            break;
        case MMClosableViewCloseButtonLocationBottomRight:
            closeButtonFrame.origin = CGPointMake(width-kCloseRegionWidth, height-kCloseRegionHeight);
            break;
        case MMClosableViewCloseButtonLocationBottomLeft:
            closeButtonFrame.origin = CGPointMake(0.0f, height-kCloseRegionHeight);
            break;
        case MMClosableViewCloseButtonLocationBottomCenter:
            closeButtonFrame.origin = CGPointMake((width-kCloseRegionWidth) / 2.0f, height-kCloseRegionHeight);
            break;
        case MMClosableViewCloseButtonLocationCenter:
            closeButtonFrame.origin = CGPointMake((width-kCloseRegionWidth) / 2.0f, (height-kCloseRegionHeight) / 2.0f);
            break;
        default:
            closeButtonFrame.origin = CGPointMake(width-kCloseRegionWidth, 0.0f);
            break;
    }
    return closeButtonFrame;
}

@interface MMClosableView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImage *closeButtonImage;

@property (nonatomic, assign) BOOL wasTapped;

@end

@implementation MMClosableView

-(instancetype)initWithFrame:(CGRect)frame closeButtonType:(MMClosableViewCloseButtonType)closeButtonType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        _closeButtonLocation = MMClosableViewCloseButtonLocationTopRight;
        
//        _userInteractionRecognizer = [[MPUserInteractionGestureRecognizer alloc] initWithTarget:self action:@selector(handleInteraction:)];
//        _userInteractionRecognizer.cancelsTouchesInView = NO;
//        [self addGestureRecognizer:_userInteractionRecognizer];
//        _userInteractionRecognizer.delegate = self;
        
        _closeButtonImage = [UIImage imageNamed:kExpandableCloseButtonImageName];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.accessibilityLabel = @"Close Interstitial Ad";
        
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self setCloseButtonType:closeButtonType];
        
        [self addSubview:_closeButton];
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.closeButton.frame = MMClosableViewCustomCloseButtonFrame(self.bounds.size, self.closeButtonLocation);
    [self bringSubviewToFront:self.closeButton];
}

- (void)didMoveToWindow
{
    if ([self.delegate respondsToSelector:@selector(closableView:didMoveToWindow:)]) {
        [self.delegate closableView:self didMoveToWindow:self.window];
    }
}

- (void)setCloseButtonType:(MMClosableViewCloseButtonType)closeButtonType
{
    _closeButtonType = closeButtonType;
    
    switch (closeButtonType) {
        case MMClosableViewCloseButtonTypeNone:
            self.closeButton.hidden = YES;
            break;
        case MMClosableViewCloseButtonTypeTappableWithoutImage:
            self.closeButton.hidden = NO;
            [self.closeButton setImage:nil forState:UIControlStateNormal];
            break;
        case MMClosableViewCloseButtonTypeTappableWithImage:
            self.closeButton.hidden = NO;
            [self.closeButton setImage:self.closeButtonImage forState:UIControlStateNormal];
            break;
        default:
            self.closeButton.hidden = NO;
            [self.closeButton setImage:self.closeButtonImage forState:UIControlStateNormal];
            break;
    }
}

- (void)setCloseButtonLocation:(MMClosableViewCloseButtonLocation)closeButtonLocation
{
    _closeButtonLocation = closeButtonLocation;
    [self setNeedsLayout];
}

- (void)handleInteraction:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.wasTapped = YES;
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
    return YES;
}

#pragma mark - <UIButton>

- (void)closeButtonPressed
{
    [self.delegate closeButtonPressed:self];
}


@end
