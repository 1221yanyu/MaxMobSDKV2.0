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



@end

@implementation MRControllerNew

-(instancetype)initWithAdViewFrame:(CGRect)adViewFrame adPlacementType:(MRAdViewPlacementType)placementType
{
    if (self = [super init]) {
        _placementType = placementType;
        _currentState = MRAdViewStateDefault;
        
        _mraidDefaultAdFrame = adViewFrame;
        
        _mraidWebView = [self buildMRAIDWebViewWithFrame:adViewFrame];
        _mraidBridge = [[MRBridge alloc] initWithWebView:_mraidWebView];
        _mraidBridge.delegate = self;
        _mraidBridge.shouldHandleRequests = YES;
    }
    return self;
}
- (MRAdView *)activeView
{
    if (self.currentState == MRAdViewStateExpanded) {
        return self.expansionContentView;
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
    NSString *htmlPath = [mraidBundle pathForResource:@"readAd" ofType:@"html"];
    NSString *HTML = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.mraidBridge loadHTMLString:HTML baseURL:nil];
    
}


#pragma mark - Executing Javascript

- (void)initializeLoadedAdForBridge:(MRBridge *)bridge
{
    // Set up some initial properties so mraid can operate.
    NSLog(@"Injecting initial JavaScript state.");
    NSArray *startingMraidProperties = @[[MRHostSDKVersionProperty defaultProperty],
                                         [MRPlacementTypeProperty propertyWithType:self.placementType],
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

#pragma mark - Property Updating
-(void)updateMRAIDProperties
{
    if (!self.isAnimatingAdSize) {
        [self fireChangeEventToBothBridgesForProperty:[MRViewableProperty propertyWithViewable:YES]];
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
            visibleFrame = self.expansionContentView.frame;
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

-(void)handleNativeCommandCloseWithBridge:(MRBridge *)bridge{
    
}
-(void)bridge:(MRBridge *)bridge performActionForMoPubSpecificURL:(NSURL *)url{
    
}
-(void)bridge:(MRBridge *)bridge handleDisplayForDestinationURL:(NSURL *)URL{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandUseCustomClose:(BOOL)useCustomClose{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:(UIInterfaceOrientationMask)forceOrientationMask{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandExpandWithURL:(NSURL *)url useCustomClose:(BOOL)useCustomClose{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandResizeWithParameters:(NSDictionary *)parameters{
    
}


- (void)adDidLoad
{
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
