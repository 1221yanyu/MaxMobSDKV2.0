//
//  TransitionAnimation.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/10.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define ANIMATIONTIME               2.0

typedef enum{
    MMAnimationNameFilpFromLeft,
    MMAnimationNameFilpFromRight,
    MMAnimationNameCurlUp,
    MMAnimationNameCurlDown,
    
    MMAnimationNamePublicPushFromTop,
    MMAnimationNamePublicPushFromBottom,
    MMAnimationNamePublicMoveInFromTop,
    MMAnimationNamePublicMoveInFromBottom,
    MMAnimationNamePublicRevealFromTop,
    MMAnimationNamePublicFadeFromTop,
    
    MMAnimationNamePrivateCube,
    MMAnimationNamePrivateSuckEffect,
    MMAnimationNamePrivateOglFlip,
    MMAnimationNamePrivateRippleEffect,
    MMAnimationNamePrivateCameraIrisHollowOpen,
    MMAnimationNamePrivateCameraIrisHollowClose,
    
    MMAnimationNameGlassBroken,
    
    MMAnimationNameSelfScaleOut,
    MMAnimationNameSelfScaleIn
    
}TransitionTypeName;
@interface Transition : NSObject //广告切换动画

+ (void)setAnimation:(UIView*)viewForAnimation withNameOfAnimation:(TransitionTypeName)nameOfAnimation;

/*****************************************************
 @method setRandomAnimation:
 @abstract 为指定的View设置随机动画
 @param viewForAnimation: 设置动画的view
 @return 无
 *****************************************************/
+ (void)setRandomAnimation:(UIView*)viewForAnimation;

/*****************************************************
 @method setUIViewAnimations:
 @abstract 设置广告位的类型
 @param typeOfAdSpace: 广告位的类型
 @return 无
 *****************************************************/
+ (void)setUIViewAnimations:(UIView*)viewForAnimation animationName:(TransitionTypeName)nameOfAnimation;

/*****************************************************
 @method setUIViewAnimations:
 @abstract 设置广告位的类型
 @param typeOfAdSpace: 广告位的类型
 @return 无
 *****************************************************/
+ (void)setPublicCATransition:(UIView*)viewForAnimation animationName:(TransitionTypeName)nameOfAnimation;

/*****************************************************
 @method setUIViewAnimations:
 @abstract 设置广告位的类型
 @param typeOfAdSpace: 广告位的类型
 @return 无
 *****************************************************/
//+ (void)setPrivateCATransition:(UIView*)viewForAnimation animationName:(AnimationName)nameOfAnimation;

//from self
/*****************************************************
 @method setAnimationOfRotationAndScale:
 @abstract 设置广告位的类型
 @param typeOfAdSpace: 广告位的类型
 @return 无
 *****************************************************/
+ (void)setAnimationOfRotationAndScale:(UIView *)viewForAnimation;

/*****************************************************
 @method setUIViewAnimations:
 @abstract 设置广告位的类型
 @param typeOfAdSpace: 广告位的类型
 @return 无
 *****************************************************/
+ (void)matchAnimations:(UIView*)viewForAnimation animationName:(int)nameOfAnimation;

/*****************************************************
 @method initWithFrame:
 @abstract 初始化方法
 @param frame: 控件初始化位置和大小
 @return 返回控件本身.nil: 初始化失败；非nil: 初始化成功
 *****************************************************/
+ (NSNumber*)getAnimation;

@end



