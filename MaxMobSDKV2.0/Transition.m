//
//  TransitionAnimation.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/10.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "Transition.h"

@implementation Transition : NSObject
+ (void)setAnimation:(UIView *)viewForAnimation withNameOfAnimation:(TransitionTypeName)nameOfAnimation{
    
    [Transition matchAnimations:viewForAnimation animationName:nameOfAnimation];
}

+ (void)setRandomAnimation:(UIView *)viewForAnimation{
    NSNumber *nameOfType = [Transition getAnimation];
    int nameInt = [nameOfType intValue]; //这里一定要保证输入的动画名称类型是整型
    
    [Transition matchAnimations:viewForAnimation animationName:nameInt];
    
}

+ (void)setUIViewAnimations:(UIView *)viewForAnimation animationName:(TransitionTypeName)nameOfAnimation{
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:ANIMATIONTIME];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    
    switch (nameOfAnimation) {
        case MMAnimationNameFilpFromLeft:
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:viewForAnimation cache:YES];//oglFlip, fromLeft
            break;
        case MMAnimationNameFilpFromRight:
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:viewForAnimation cache:YES];//oglFlip, fromRight
            break;
        case MMAnimationNameCurlUp:
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:viewForAnimation cache:YES];
            break;
        case MMAnimationNameCurlDown:
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:viewForAnimation cache:YES];
            break;
        default:
            break;
    }
    
    [UIView commitAnimations];
    
}

+ (void)setPublicCATransition:(UIView *)viewForAnimation animationName:(TransitionTypeName)nameOfAnimation{
    CATransition *animation = [CATransition animation];
    animation.delegate = [Transition class];
    animation.duration = 0.3;
    //animation.timingFunction = UIViewAnimationCurveEaseInOut; // 此行代码无效，执行结果左端指针为空
    animation.fillMode = kCAFillModeForwards;
    //animation.removedOnCompletion = NO;
    
    /*
     kCATransitionFade;
     kCATransitionMoveIn;
     kCATransitionPush;
     kCATransitionReveal;
     */
    /*
     kCATransitionFromRight;
     kCATransitionFromLeft;
     kCATransitionFromTop;
     kCATransitionFromBottom;
     */
    switch (nameOfAnimation) {
        case MMAnimationNamePublicPushFromTop:
            animation.type = kCATransitionPush;
            animation.subtype = kCATransitionFromTop;
            break;
        case MMAnimationNamePublicPushFromBottom:
            animation.type = kCATransitionPush;
            animation.subtype = kCATransitionFromBottom;
            viewForAnimation.hidden = YES;
            break;
        case MMAnimationNamePublicMoveInFromTop:
            animation.type = kCATransitionMoveIn;
            animation.subtype = kCATransitionFromTop;
            break;
        case MMAnimationNamePublicMoveInFromBottom:
            animation.type = kCATransitionMoveIn;
            animation.subtype = kCATransitionFromBottom;
            break;
        case MMAnimationNamePublicRevealFromTop:
            animation.type = kCATransitionReveal;
            animation.subtype = kCATransitionFromTop;
            break;
        case MMAnimationNamePublicFadeFromTop:
            animation.type = kCATransitionFade;
            animation.subtype = kCATransitionFromTop;
            break;
        default:
            break;
    }
    
    [viewForAnimation.layer addAnimation:animation forKey:@"animation"];
    
}

//from self animations
+ (void)setAnimationOfRotationAndScale:(UIView *)viewForAnimation{
    static int      theta;
    
    // Rotate each iteration by 1% of PI
    CGFloat angle = theta * (M_PI / 100.0f);
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
    
    // Theta ranges between 0% and 199% of PI, i.e. between 0 and 2*PI
    theta = (theta + 1) % 200;
    
    // For fun, scale by the absolute value of the cosine
    float degree = cos(angle);
    if (degree < 0.0) degree *= -1.0f;
    degree += 0.5f;
    
    // Create add scaling to the rotation transform
    CGAffineTransform scaled = CGAffineTransformScale(transform, degree, degree);
    
    // Apply the affine transform
    [viewForAnimation setTransform:scaled];
    
    CGContextRef context = UIGraphicsGetCurrentContext();//return the top uiview in the heap or stack
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:ANIMATIONTIME];
    
    viewForAnimation.transform = CGAffineTransformIdentity;
    
    [UIView setAnimationDelegate:[Transition class]];
    [UIView commitAnimations];
    
}


/*
 */
+ (void)setPrivateCATransition:(UIView *)viewForAnimation animationName:(TransitionTypeName)nameOfAnimation{
    CATransition *animation = [CATransition animation];
    animation.delegate = [Transition class];
    animation.duration = ANIMATIONTIME;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    switch (nameOfAnimation) {
        case MMAnimationNamePrivateCube:
            animation.type = @"cube";//---
            break;
        case MMAnimationNamePrivateSuckEffect:
            animation.type = @"suckEffect";//103
            break;
        case MMAnimationNamePrivateOglFlip:
            animation.type = @"oglFlip";//When subType is "fromLeft" or "fromRight", it's the official one.
            break;
        case MMAnimationNamePrivateRippleEffect:
            animation.type = @"rippleEffect";//110
            break;
        case MMAnimationNamePrivateCameraIrisHollowOpen:
            animation.type = @"cameraIrisHollowOpen ";//107
            break;
        case MMAnimationNamePrivateCameraIrisHollowClose:
            animation.type = @"cameraIrisHollowClose ";//106
            break;
        default:
            break;
    }
    
    [viewForAnimation.layer addAnimation:animation forKey:@"animation"];
}

+ (void)setAnimationOfScale:(UIView *)viewForAnimation{
    CGContextRef context = UIGraphicsGetCurrentContext();//return the top uiview in the heap or stack
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:2.0];
    
    static int theta = 0;
    // Rotate each iteration by 1% of PI
    CGFloat angle = theta * (M_PI / 100.0f);
    // Theta ranges between 0% and 199% of PI, i.e. between 0 and 2*PI
    theta = (theta + 1) % 200;
    
    // For fun, scale by the absolute value of the cosine
    float degree = cos(angle);
    if (degree < 0.0) degree *= -1.0f;
    degree += 0.5f;
    
    CGAffineTransform scaled = CGAffineTransformMakeScale(degree, degree);
    [UIView setAnimationDelegate:[Transition class]];
    viewForAnimation.transform = scaled;
    viewForAnimation.transform = CGAffineTransformIdentity;
    //[UIView setAnimationDidStopSelector:@selector(animationFinished:)];
    [UIView commitAnimations];
    
    
}

+ (void)setUIViewAnimationOfScaledEase:(UIView *)viewForAnimation{
    
    CGContextRef context = UIGraphicsGetCurrentContext();//return the top uiview in the heap or stack
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationDuration:2.0];
    
    viewForAnimation.alpha = 1.0f;
    viewForAnimation.alpha = 0.0f;
    
    viewForAnimation.transform = CGAffineTransformMakeScale(0.25f, 0.25f);
    viewForAnimation.transform = CGAffineTransformIdentity;
    
    [viewForAnimation exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    
    [UIView setAnimationDelegate:[Transition class]];
    [UIView commitAnimations];
}

+ (void)matchAnimations:(UIView*)viewForAnimation animationName:(int)nameOfAnimation{
    switch (nameOfAnimation) {
            
        case MMAnimationNameFilpFromLeft:
        case MMAnimationNameFilpFromRight:
        case MMAnimationNameCurlUp:
        case MMAnimationNameCurlDown:
            [Transition setUIViewAnimations:viewForAnimation animationName:nameOfAnimation];
            break;
            
        case MMAnimationNamePublicPushFromTop:
        case MMAnimationNamePublicPushFromBottom:
        case MMAnimationNamePublicMoveInFromTop:
        case MMAnimationNamePublicRevealFromTop:
        case MMAnimationNamePublicFadeFromTop:
            [Transition setPublicCATransition:viewForAnimation animationName:nameOfAnimation];
            break;
            
        case MMAnimationNamePrivateCube:
        case MMAnimationNamePrivateSuckEffect:
        case MMAnimationNamePrivateRippleEffect:
        case MMAnimationNamePrivateCameraIrisHollowOpen:
        case MMAnimationNamePrivateCameraIrisHollowClose:
            [Transition setPrivateCATransition:viewForAnimation animationName:nameOfAnimation];
            break;
            
        case MMAnimationNameSelfScaleIn:
            [Transition setAnimationOfScale:viewForAnimation];
            break;
        case MMAnimationNameSelfScaleOut:
            [Transition setUIViewAnimationOfScaledEase:viewForAnimation];
            break;
        default:
            break;
    }
    
}

+ (NSNumber*)getAnimation{
    
    const int name[] = {MMAnimationNameFilpFromLeft, MMAnimationNameFilpFromRight, MMAnimationNameCurlUp, MMAnimationNameCurlDown,MMAnimationNamePrivateCube, MMAnimationNamePrivateSuckEffect,MMAnimationNamePrivateRippleEffect};
    
    unsigned int nameCount = sizeof(name)/(sizeof(name[0]));
    
    NSMutableArray *animationName = [[NSMutableArray alloc]initWithCapacity:nameCount];
    
    for (int i = 0; i < nameCount; i++) {
        NSNumber *number = [NSNumber numberWithInt:name[i]];
        [animationName insertObject:number atIndex:i];
        number = nil;
    }
    
    NSInteger indexOfBegin = (random()%nameCount);
    
    return [animationName objectAtIndex:indexOfBegin];
}

@end
