//
//  MRControllerNew.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/19.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MRControllerNew.h"
#import "MRBridge.h"
#import "MRAdView.h"
#import "MRProperty.h"
#import "MMClosableView.h"
#import "MPGlobal.h"

@interface MRControllerNew () <MRBridgeDelegate>
{
    UIButton *closeButton;
}
@property (nonatomic, strong) MRBridge *mraidBridge;
@property (nonatomic, strong) UIWebView *mraidWebView;
@property (nonatomic, assign) NSUInteger modalViewCount;
@property (nonatomic, assign) MRAdViewState currentState;
@property (nonatomic, assign) MRAdViewPlacementType placementType;
@property (nonatomic, strong) MRAdView *expansionContentView;
@property (nonatomic, weak) UIView *originalSuperview;
@property (nonatomic, assign) CGRect mraidDefaultAdFrame;
@property (nonatomic, assign) CGSize currentAdSize;
@property (nonatomic, assign) BOOL isAnimatingAdSize;
@property (nonatomic, assign) BOOL isViewable;

@property (nonatomic, assign) UIInterfaceOrientationMask forceOrientationMask;
@property (nonatomic, copy) void (^forceOrientationAfterAnimationBlock)();


@end

@implementation MRControllerNew

-(instancetype)initWithAdViewFrame:(CGRect)adViewFrame adPlacementType:(MRAdViewPlacementType)placementType
{
    if (self = [super init]) {
        _prepareAd = NO;
        _placementType = placementType;
        _currentState = MRAdViewStateDefault;
        
        _mraidDefaultAdFrame = adViewFrame;
        _mraidWebView = [self buildMRAIDWebViewWithFrame:adViewFrame];
        _originalSuperview = _mraidWebView.superview;
        _mraidBridge = [[MRBridge alloc] initWithWebView:_mraidWebView];
        _mraidBridge.delegate = self;
        _mraidBridge.shouldHandleRequests = YES;
        
        /* 注册监听view进入后台事件 */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        /* 注册监听view后台唤醒事件 */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}
- (MRAdView *)activeView
{
    if (self.currentState == MRAdViewStateExpanded) {
        return self.mraidWebView;
    }
    
    return self.mraidWebView;
}
- (MRBridge *)bridgeForAdView:(MRAdView *)view
{
    return self.mraidBridge;
}

- (MRBridge *)bridgeForActiveAdView
{
    MRBridge *bridge = [self bridgeForAdView:[self activeView]];
    return bridge;
}

- (UIWebView *)buildMRAIDWebViewWithFrame:(CGRect)frame
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.backgroundColor = [UIColor clearColor];
    webView.clipsToBounds = YES;
    webView.opaque = NO;
    [self mp_setScrollable:NO webView:webView];  //找到所有子视图UIScrollViews或子类和设置他们的滚动和反弹
    
    if ([webView respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
        [webView setAllowsInlineMediaPlayback:YES];
    }
    
    if ([webView respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
        [webView setMediaPlaybackRequiresUserAction:NO];
    }
    
    return webView;
}
- (void)mp_setScrollable: (BOOL)scrollable  webView:(UIWebView *)webView {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000 // iOS 5.0+
    if ([self respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scrollView = webView.scrollView;
        scrollView.scrollEnabled = scrollable;
        scrollView.bounces = scrollable;
    }
    else
#endif
    {
        UIScrollView *scrollView = nil;
        for (UIView *v in webView.subviews)
        {
            if ([v isKindOfClass:[UIScrollView class]])
            {
                scrollView = (UIScrollView *)v;
                break;
            }
        }
        scrollView.scrollEnabled = scrollable;
        scrollView.bounces = scrollable;
    }
}

-(void)loadAdWithConfiguration:(MMAdConfiguration *)configuration
{
    //    NSString *HTML = [configuration adResponseHTMLString];
    
    NSBundle *parentBundle = [NSBundle mainBundle];
    NSString *mraidBundlePath = [parentBundle pathForResource:@"MRAID" ofType:@"bundle"];
    NSBundle *mraidBundle = [NSBundle bundleWithPath:mraidBundlePath];
    NSString *htmlPath = [mraidBundle pathForResource:TestHTMLExpand ofType:@"html"];
    NSString *HTML = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.mraidBridge loadHTMLString:HTML baseURL:nil];
    
}
-(void)loadAdWithHTML:(NSString *)html
{
    [self.mraidBridge loadHTMLString:html baseURL:nil];
}

-(void)clickCloseBtn
{
    _mraidWebView.frame= _mraidDefaultAdFrame;
    self.currentState = MRAdViewStateDefault;
    NSArray *startingMraidProperties = @[[MRPlacementTypeProperty propertyWithType:self.placementType],
                                         [MRSupportsProperty defaultProperty],
                                         [MRStateProperty propertyWithState:self.currentState]
                                         ];
    MRBridge *bridge = [self bridgeForActiveAdView];
    [bridge fireChangeEventsForProperties:startingMraidProperties];
    [bridge fireCommandCompleted:@"close"];
    closeButton.hidden = YES;
}



#pragma mark - Execute

-(void)setCloseButton
{
//    _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(_mraidWebView.frame.size.width-40, 0, 40, 40)];
    closeButton  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeButton.frame = CGRectMake(_mraidWebView.frame.size.width-40, 0, 40, 40);
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MRAID" ofType:@"bundle"]];
    NSString *imageURL = [bundle pathForResource:@"CloseBtn" ofType:@"png"];
    [closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:imageURL] forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor clearColor];
}

-(void)orientation:(MRBridge *)bridge command:(NSString *)command properties:(NSDictionary *)properties
{
    UIInterfaceOrientationMask forceOrientationMaskValue;
    NSString *forceOrientationString = properties[@"forceOrientation"];
    
    // Give a default value of "none" for forceOrientationString if it didn't come in through the params.
    if (!forceOrientationString) {
        forceOrientationString = kOrientationPropertyForceOrientationNoneKey;
    }
    
    // Do not allow orientation changing if we're given a force orientation other than none. Based on the spec,
    // we believe that forceOrientation takes precedence over allowOrientationChange and should not allow
    // orientation changes when a forceOrientation other than 'none' is given.
    if ([forceOrientationString isEqualToString:kOrientationPropertyForceOrientationPortraitKey]) {
        forceOrientationMaskValue = UIInterfaceOrientationMaskPortrait;
    } else if ([forceOrientationString isEqualToString:kOrientationPropertyForceOrientationLandscapeKey]) {
        forceOrientationMaskValue = UIInterfaceOrientationMaskLandscape;
    } else {
        // Default allowing orientation change to YES. We will change this only if we received a value for this in our params.
        BOOL allowOrientationChangeValue = YES;
        
        // If we end up allowing orientation change, then we're going to allow any orientation.
        forceOrientationMaskValue = UIInterfaceOrientationMaskAll;
        
        NSObject *allowOrientationChangeObj = properties[@"allowOrientationChange"];
        
        if (allowOrientationChangeObj) {
            allowOrientationChangeValue = [self boolFromParameters:properties forKey:@"allowOrientationChange"];
        }
        
        // If we don't allow orientation change, we're locking the user into the current orientation.
        if (!allowOrientationChangeValue) {
            UIInterfaceOrientation currentOrientation = MPInterfaceOrientation();
            
            if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
                forceOrientationMaskValue = UIInterfaceOrientationMaskLandscape;
            } else if (currentOrientation == UIInterfaceOrientationPortrait) {
                forceOrientationMaskValue = UIInterfaceOrientationMaskPortrait;
            } else if (currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                forceOrientationMaskValue = UIInterfaceOrientationMaskPortraitUpsideDown;
            }
        }
    }
    [self bridge:bridge handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:forceOrientationMaskValue];
    [bridge fireCommandCompleted:command];
}

-(void)expand:(MRBridge *)bridge command:(NSString *)command properties:(NSDictionary *)properties
{
    CGRect screenFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _mraidWebView.frame= screenFrame;
    NSURL *url = [self urlFromParameters:properties forKey:@"url"];
    if (url) {
        NSLog(@"%@",url);
    }
    NSString *usrCustomClose = [properties valueForKey:@"shouldUseCustomClose"];
    if ([usrCustomClose isEqualToString:@"false"]) {
        [self setCloseButton];
        closeButton.hidden = NO;
        [closeButton addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        [_mraidWebView addSubview:closeButton];
    }
    self.currentState = MRAdViewStateExpanded;
    NSArray *startingMraidProperties = @[[MRPlacementTypeProperty propertyWithType:self.placementType],
                                         [MRSupportsProperty defaultProperty],
                                         [MRStateProperty propertyWithState:self.currentState]
                                         ];
    [bridge fireChangeEventsForProperties:startingMraidProperties];
    [bridge fireCommandCompleted:command];

}

- (BOOL)executeWithParams:(NSDictionary *)params
{
    NSURL *url = [self urlFromParameters:params forKey:@"url"];
    
    NSDictionary *expandParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                  (url == nil) ? [NSNull null] : url , @"url",
                                  [NSNumber numberWithBool:[self boolFromParameters:params forKey:@"shouldUseCustomClose"]], @"useCustomClose",
                                  nil];
    
    return YES;
}

- (BOOL)boolFromParameters:(NSDictionary *)parameters forKey:(NSString *)key
{
    NSString *stringValue = [parameters valueForKey:key];
    return [stringValue isEqualToString:@"true"] || [stringValue isEqualToString:@"1"];
}

- (NSString *)stringFromParameters:(NSDictionary *)parameters forKey:(NSString *)key
{
    NSString *value = [parameters objectForKey:key];
    if (!value || [value isEqual:[NSNull null]]) return nil;
    
    value = [value stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!value || [value isEqual:[NSNull null]] || value.length == 0) return nil;
    
    return value;
}

- (NSURL *)urlFromParameters:(NSDictionary *)parameters forKey:(NSString *)key
{
    NSString *value = [self stringFromParameters:parameters forKey:key];
    return [NSURL URLWithString:value];
}



#pragma mark - Executing Javascript

- (void)initializeLoadedAdForBridge:(MRBridge *)bridge
{
    // Set up some initial properties so mraid can operate.
    NSLog(@"Injecting initial JavaScript state.");
    NSArray *startingMraidProperties = @[[MRPlacementTypeProperty propertyWithType:self.placementType],
                                         [MRSupportsProperty defaultProperty],
                                         [MRStateProperty propertyWithState:self.currentState]
                                         ];
    
    [bridge fireChangeEventsForProperties:startingMraidProperties];
    
    [self updateMRAIDProperties];
    [bridge fireReadyEvent];
}

- (void)fireChangeEventToBothBridgesForProperty:(MRProperty *)property
{
    [self.mraidBridge fireChangeEventForProperty:property];
    //    [self.mraidBridgeTwoPart fireChangeEventForProperty:property];
}


#pragma mark - Viewability Helpers

- (void)checkViewability
{
    BOOL viewable = MPViewIsVisible([self activeView]) && ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive);
    [self updateViewabilityWithBool:viewable];
}

- (void)viewEnteredBackground
{
    [self updateViewabilityWithBool:NO];
}

-(void)viewEnteredForeground
{
    [self updateViewabilityWithBool:YES];
}

- (void)updateViewabilityWithBool:(BOOL)currentViewability
{
    if (self.isViewable != currentViewability)
    {
        NSLog(@"Viewable changed to: %@", currentViewability ? @"YES" : @"NO");
        self.isViewable = currentViewability;
        
        // Both views in two-part expand need to report if they're viewable or not depending on the active one.
        [self fireChangeEventToBothBridgesForProperty:[MRViewableProperty propertyWithViewable:self.isViewable]];
    }
}


#pragma mark - Property Updating
-(void)updateMRAIDProperties
{
    if (!self.isAnimatingAdSize) {
        [self checkViewability];
        [self updateCurrentPosition];
        [self updateDefaultPosition];
        [self updateScreenSize];
        [self updateMaxSize];
        [self updateEventSizeChange];
    }
}

- (CGRect)activeAdFrameInScreenSpace
{
    CGRect visibleFrame = CGRectZero;
    
    if (self.placementType == MRAdViewPlacementTypeInline) {
        if (self.currentState == MRAdViewStateExpanded) {
            // We're in a modal so we can just return the expanded view's frame.
            visibleFrame = self.mraidWebView.frame;
        } else {
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            visibleFrame = [self.mraidWebView.superview convertRect:self.mraidWebView.frame toView:keyWindow.rootViewController.view];
        }
    } else if (self.placementType == MRAdViewPlacementTypeInterstitial) {
        visibleFrame = self.mraidWebView.frame;
    }
    
    return visibleFrame;
}

- (CGRect)defaultAdFrameInScreenSpace
{
    CGRect defaultFrame = CGRectZero;
    
    if (self.placementType == MRAdViewPlacementTypeInline) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        defaultFrame = [self.originalSuperview convertRect:self.mraidDefaultAdFrame toView:keyWindow.rootViewController.view];
    } else if (self.placementType == MRAdViewPlacementTypeInterstitial) {
        defaultFrame = self.mraidWebView.frame;
    }
    
    return defaultFrame;
}

- (void)updateCurrentPosition
{
    CGRect frame = [self activeAdFrameInScreenSpace];
    
    // Only fire to the active ad view.
    MRBridge *activeBridge = [self bridgeForActiveAdView];
    [activeBridge fireSetCurrentPositionWithPositionRect:frame];
    
    NSLog(@"Current Position: %@", NSStringFromCGRect(frame));
}

- (void)updateDefaultPosition
{
    CGRect defaultFrame = [self defaultAdFrameInScreenSpace];
    // Not necessary to fire to both ad views, but it's better that the two-part expand knows the default position than not.
    [self.mraidBridge fireSetDefaultPositionWithPositionRect:defaultFrame];
    NSLog(@"Default Position: %@", NSStringFromCGRect(defaultFrame));
}

- (void)updateScreenSize
{
    // Fire an event for screen size changing. This includes the area of the status bar in its calculation.
    CGSize screenSize = MPScreenBounds().size;
    
    // Fire to both ad views as it pertains to both views.
    [self.mraidBridge fireSetScreenSize:screenSize];
    
    NSLog(@"Screen Size: %@", NSStringFromCGSize(screenSize));
}

- (void)updateMaxSize
{
    // Similar to updateScreenSize except this doesn't include the area of the status bar in its calculation.
    CGSize maxSize = MPApplicationFrame().size;
    
    // Fire to both ad views as it pertains to both views.
    [self.mraidBridge fireSetMaxSize:maxSize];
    
    NSLog(@"Max Size: %@", NSStringFromCGSize(maxSize));
}

- (void)updateEventSizeChange
{
    CGSize adSize = [self activeAdFrameInScreenSpace].size;
    
    // Firing the size change event will broadcast the event to the ad. The ad may subscribe to this event and
    // perform some action when it receives the event. As a result, we don't want to have the ad do any work
    // when the size hasn't changed. So we make sure we don't fire the size change event unless the size has
    // actually changed. We don't place similar guards around updating properties that don't broadcast events
    // since the ad won't be notified when we update the properties. Thus, the ad can't do any unnecessary work
    // when we update other properties.
    if (!CGSizeEqualToSize(adSize, self.currentAdSize)) {
        MRBridge *activeBridge = [self bridgeForActiveAdView];
        self.currentAdSize = adSize;
        
        NSLog(@"Ad Size (Size Event): %@", NSStringFromCGSize(self.currentAdSize));
        [activeBridge fireSizeChangeEvent:adSize];
    }
}


#pragma mark - <MRBridgeDelegate>

-(BOOL)isLoadingAd{
    return YES;
}
-(MRAdViewPlacementType)placementType{
    return MRAdViewPlacementTypeInline;
}
-(BOOL)hasUserInteractedWithWebViewForBridge:(MRBridge *)bridge{
    return YES;
}
-(UIViewController *)viewControllerForPresentingModalView{
    UIViewController *expandView = [[UIViewController alloc]init];
    return expandView;
}

-(void)nativeCommandWillPresentModalView{
    
}
-(void)nativeCommandDidDismissModalView{
    
}

-(void)bridge:(MRBridge *)bridge didFinishLoadingWebView:(UIWebView *)webView{
    [self adDidLoad];   // 返回加载的广告页面
    [self initializeLoadedAdForBridge:bridge];      //开始注入JS脚本
}
-(void)bridge:(MRBridge *)bridge didFailLoadingWebView:(UIWebView *)webView error:(NSError *)error
{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommand:(NSString *)command withProperties:(NSDictionary *)properties
{
    NSLog(@"command is %@",command);
    if ([command isEqualToString:CommandExpand]) {
        
        [self expand:bridge command:command properties:properties];
        
    }else if ([command isEqualToString:CommandSetOrientationProperties])
    {
        [self orientation:bridge command:command properties:properties];
    }else if ([command isEqualToString:CommandClose])
    {
        
    }
}

-(void)handleNativeCommandCloseWithBridge:(MRBridge *)bridge{
    
}
-(void)bridge:(MRBridge *)bridge performActionForMoPubSpecificURL:(NSURL *)url{
    
}
-(void)bridge:(MRBridge *)bridge handleDisplayForDestinationURL:(NSURL *)URL{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandUseCustomClose:(BOOL)useCustomClose{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:(UIInterfaceOrientationMask)forceOrientationMask{
    
    // If the ad is trying to force an orientation that the app doesn't support, we shouldn't try to force the orientation.
    if (![[UIApplication sharedApplication] mp_supportsOrientationMask:forceOrientationMask]) {
        return;
    }
    
    BOOL inExpandedState = self.currentState == MRAdViewStateExpanded;
    
    // If we aren't expanded or showing an interstitial ad, we don't have to force orientation on our ad.
    if (!inExpandedState && self.placementType != MRAdViewPlacementTypeInterstitial) {
        return;
    }
    
    // If request handling is paused, we want to queue up this method to be called again when they are re-enabled.
    if (!bridge.shouldHandleRequests) {
        __weak __typeof__(self) weakSelf = self;
        self.forceOrientationAfterAnimationBlock = ^void() {
            __typeof__(self) strongSelf = weakSelf;
            [strongSelf bridge:bridge handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:forceOrientationMask];
        };
        return;
    }
    
    // By this point, we've committed to forcing the orientation so we don't need a forceOrientationAfterAnimationBlock.
    self.forceOrientationAfterAnimationBlock = nil;
    self.forceOrientationMask = forceOrientationMask;
    
    BOOL inSameOrientation = [[UIApplication sharedApplication] mp_doesOrientation:MPInterfaceOrientation() matchOrientationMask:forceOrientationMask];
//    UIViewController <MPForceableOrientationProtocol> *fullScreenAdViewController = inExpandedState ? self.expandModalViewController : self.interstitialViewController;
//    
//    // If we're currently in the force orientation, we don't need to do any rotation.  However, we still need to make sure
//    // that the view controller knows to use the forced orientation when the user rotates the device.
//    if (inSameOrientation) {
//        _mraidWebView.su
//        fullScreenAdViewController.supportedOrientationMask = forceOrientationMask;
//    } else {
//        // It doesn't seem possible to force orientation in iOS 7+. So we dismiss the current view controller and re-present it with the forced orientation.
//        // If it's an expanded ad, we need to restore the status bar visibility before we dismiss the current VC since we don't show the status bar in expanded state.
//        if (inExpandedState) {
//            [self.expandModalViewController restoreStatusBarVisibility];
//        }
//        
//        // Block our timer from updating properties while we force orientation on the view controller.
//        [self willBeginAnimatingAdSize];
//        
//        UIViewController *presentingViewController = fullScreenAdViewController.presentingViewController;
//        __weak __typeof__(self) weakSelf = self;
//        [fullScreenAdViewController dismissViewControllerAnimated:NO completion:^{
//            __typeof__(self) strongSelf = weakSelf;
//            
//            if (inExpandedState) {
//                [strongSelf didEndAnimatingAdSize];
//                
//                // If expanded, we don't need to change the state of the ad once the modal is present here as the ad is technically
//                // always in the expanded state throughout the process of dismissing and presenting.
//                [strongSelf presentExpandModalViewControllerWithView:strongSelf.expansionContentView animated:NO completion:^{
//                    [strongSelf updateMRAIDProperties];
//                }];
//            } else {
//                fullScreenAdViewController.supportedOrientationMask = forceOrientationMask;
//                [presentingViewController presentViewController:fullScreenAdViewController animated:NO completion:^{
//                    [strongSelf didEndAnimatingAdSize];
//                    strongSelf.currentInterfaceOrientation = MPInterfaceOrientation();
//                    [strongSelf updateMRAIDProperties];
//                }];
//            }
//        }];
//    }
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandExpandWithURL:(NSURL *)url useCustomClose:(BOOL)useCustomClose{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandResizeWithParameters:(NSDictionary *)parameters{
    
}


- (void)adDidLoad
{
    _prepareAd = YES;
    [self.delegate adDidLoad:self.mraidWebView];
}

- (void)adDidFailToLoad
{
     [self.delegate adDidFailToLoad:self.mraidWebView];
}

- (void)adWillClose
{
//    if ([self.delegate respondsToSelector:@selector(adWillClose:)]) {
//        [self.delegate adWillClose:self.mraidAdView];
//    }
}

- (void)adDidClose
{
//    if ([self.delegate respondsToSelector:@selector(adDidClose:)]) {
//        [self.delegate adDidClose:self.mraidAdView];
//    }
}

- (void)adWillPresentModalView
{
//    self.modalViewCount++;
//    if (self.modalViewCount == 1) {
//        [self appShouldSuspend];
//    }
}

- (void)adDidDismissModalView
{
    self.modalViewCount--;
    if (self.modalViewCount == 0) {
        [self appShouldResume];
    }
}

- (void)appShouldSuspend
{
    if ([self.delegate respondsToSelector:@selector(appShouldSuspendForAd:)]) {
        [self.delegate appShouldSuspendForAd:self.mraidWebView];
    }
}

- (void)appShouldResume
{
    if ([self.delegate respondsToSelector:@selector(appShouldResumeFromAd:)]) {
        [self.delegate appShouldResumeFromAd:self.mraidWebView];
    }
}

@end
