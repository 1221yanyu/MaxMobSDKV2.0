//
//  MRController.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/4.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MRController.h"
#import "MRBridge.h"
#import "MRCommand.h"
#import "MRProperty.h"
#import "MMClosableView.h"
#import "MMAdConfiguration.h"
#import "UIWebView+MMAdditions.h"
#import "MPTimer.h"

static const NSTimeInterval kAdPropertyUpdateTimerInterval = 1.0;
static const NSTimeInterval kMRAIDResizeAnimationTimeInterval = 0.3;

static NSString *const kMRAIDCommandExpand = @"expand";
static NSString *const kMRAIDCommandResize = @"resize";

@interface MRController () <MRBridgeDelegate,MMClosableViewDelegate>

@property (nonatomic, strong) MRBridge *mraidBridge;
@property (nonatomic, assign) MRAdViewPlacementType placementType;
@property (nonatomic, assign) MRAdViewState currentState;
@property (nonatomic, assign) CGSize currentAdSize;
@property (nonatomic, assign) CGRect mraidDefaultAdFrame;
@property (nonatomic, strong) UIView *resizeBackgroundView;
@property (nonatomic, assign) NSUInteger modalViewCount;
@property (nonatomic, assign) BOOL firedReadyEventForDefaultAd;
@property (nonatomic, strong) MPTimer *adPropertyUpdateTimer;


@property (nonatomic, strong) MMClosableView *mraidAdView;

@property (nonatomic, assign) BOOL isAdLoading;

// Points to mraidAdView (one-part expand) or mraidAdViewTwoPart (two-part expand) while expanded.
@property (nonatomic, strong) MMClosableView *expansionContentView;


// Use UIInterfaceOrientationMaskALL to specify no forcing.
@property (nonatomic, assign) UIInterfaceOrientationMask forceOrientationMask;

@property (nonatomic, assign) UIInterfaceOrientation currentInterfaceOrientation;

@property (nonatomic, copy) void (^forceOrientationAfterAnimationBlock)();

@end

@implementation MRController

-(instancetype)initWithAdViewFrame:(CGRect)adViewFrame adPlacementType:(MRAdViewPlacementType)placementType 
{
    if (self = [super init]) {
        _placementType = placementType;
        _currentState = MRAdViewStateDefault;
        _currentAdSize = CGSizeZero;
        
        _mraidDefaultAdFrame = adViewFrame;
        
        _resizeBackgroundView = [[UIView alloc]initWithFrame:adViewFrame];
        _resizeBackgroundView.backgroundColor = [UIColor clearColor];
        
        UIWebView *webView = [self buildMRAIDWebViewWithFrame:adViewFrame];
        
        _mraidBridge = [[MRBridge alloc] initWithWebView:webView];
        _mraidBridge.delegate = self;
        _mraidBridge.shouldHandleRequests = YES;
        
        _mraidAdView = [[MMClosableView alloc]initWithFrame:adViewFrame closeButtonType:MMClosableViewCloseButtonTypeTappableWithImage];
        _mraidAdView.delegate = self;
        _mraidAdView.clipsToBounds = YES;
        webView.frame = _mraidAdView.bounds;
        [_mraidAdView addSubview:webView];
        
    }
    return self;
}



#pragma mark - Public

-(void)loadAdWithConfiguration:(MMAdConfiguration *)configuration
{
    self.isAdLoading = YES;
    
//    NSString *HTML = [configuration adResponseHTMLString];
    
    NSBundle *parentBundle = [NSBundle mainBundle];
    NSString *mraidBundlePath = [parentBundle pathForResource:@"MRAID" ofType:@"bundle"];
    NSBundle *mraidBundle = [NSBundle bundleWithPath:mraidBundlePath];
    NSString *htmlPath = [mraidBundle pathForResource:@"readAd" ofType:@"html"];
    NSString *HTML = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.mraidBridge loadHTMLString:HTML baseURL:nil];
    
}
- (void)enableRequestHandling
{
    self.mraidBridge.shouldHandleRequests = YES;
//    self.mraidBridgeTwoPart.shouldHandleRequests = YES;
    // If orientation has been forced while requests are disabled (during animation), we need to execute that command through the block forceOrientationAfterAnimationBlock() after the presentation completes.
    if (self.forceOrientationAfterAnimationBlock) {
        self.forceOrientationAfterAnimationBlock();
        self.forceOrientationAfterAnimationBlock = nil;
    }
}

- (void)disableRequestHandling
{
    self.mraidBridge.shouldHandleRequests = NO;
//    self.mraidBridgeTwoPart.shouldHandleRequests = NO;
//    [self.destinationDisplayAgent cancel];
}

#pragma mark - Private
//- (void)initAdAlertManager:(id<MPAdAlertManagerProtocol>)adAlertManager forAdView:(MPClosableView *)adView
//{
//    adAlertManager.adConfiguration = [self.delegate adConfiguration];
//    adAlertManager.adUnitId = [self.delegate adUnitId];
//    adAlertManager.targetAdView = adView;
//    adAlertManager.location = [self.delegate location];
//    [adAlertManager beginMonitoringAlerts];
//}

- (MMClosableView *)adViewForBridge:(MRBridge *)bridge
{
//    if (bridge == self.mraidBridgeTwoPart) {
//        return self.mraidAdViewTwoPart;
//    }
    
    return self.mraidAdView;
}

- (MRBridge *)bridgeForAdView:(MMClosableView *)view
{
//    if (view == self.mraidAdViewTwoPart) {
//        return self.mraidBridgeTwoPart;
//    }
    
    return self.mraidBridge;
}

- (MMClosableView *)activeView
{
    if (self.currentState == MRAdViewStateExpanded) {
        return self.expansionContentView;
    }
    
    return self.mraidAdView;
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
//    [webView mp_setScrollable:NO];   //找到所有子视图UIScrollViews或子类和设置他们的滚动和反弹
    
    if ([webView respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
        [webView setAllowsInlineMediaPlayback:YES];
    }
    
    if ([webView respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
        [webView setMediaPlaybackRequiresUserAction:NO];
    }
    
    return webView;
}


#pragma mark - Orientation Notifications

- (void)orientationDidChange:(NSNotification *)notification
{
    // We listen for device notification changes because at that point our ad's frame is in
    // the correct state; however, MRAID updates should only happen when the interface changes, so the update logic is only executed if the interface orientation has changed.
    
    //MPInterfaceOrientation is guaranteed to be the new orientation at this point.
    UIInterfaceOrientation newInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (newInterfaceOrientation != self.currentInterfaceOrientation) {
        // Update all properties and fire a size change event.
//        [self updateMRAIDProperties];
        
        //According to MRAID Specs, a resized ad should close when there's an orientation change
        //due to unpredictability of the new layout.
        if (self.currentState == MRAdViewStateResized) {
//            [self close];
        }
        
        self.currentInterfaceOrientation = newInterfaceOrientation;
    }
}
#pragma mark - Executing Javascript

- (void)initializeLoadedAdForBridge:(MRBridge *)bridge
{
    // Set up some initial properties so mraid can operate.
    NSLog(@"Injecting initial JavaScript state.");
//    NSArray *startingMraidProperties = @[[MRHostSDKVersionProperty defaultProperty],
//                                         [MRPlacementTypeProperty propertyWithType:self.placementType],
//                                         [MRSupportsProperty defaultProperty],
//                                         [MRStateProperty propertyWithState:self.currentState]
//                                         ];
//    
//    [bridge fireChangeEventsForProperties:startingMraidProperties];
    
//    [self updateMRAIDProperties];
    
    [bridge fireReadyEvent];
}

- (void)fireChangeEventToBothBridgesForProperty:(MRProperty *)property
{
    [self.mraidBridge fireChangeEventForProperty:property];
//    [self.mraidBridgeTwoPart fireChangeEventForProperty:property];
}



#pragma mark - <MRBridgeDelegate>

-(BOOL)isLoadingAd
{
    return self.isAdLoading;
}

-(MRAdViewPlacementType)placementType
{
    return MRAdViewPlacementTypeInline;
}

-(BOOL)hasUserInteractedWithWebViewForBridge:(MRBridge *)bridge
{
    if (self.placementType == MRAdViewPlacementTypeInterstitial || self.currentState == MRAdViewStateExpanded) {
        return YES;
    }
    
    MMClosableView *adView = [self adViewForBridge:bridge];
    return adView.wasTapped;
}

-(UIViewController *)viewControllerForPresentingModalView
{
    UIViewController *delegateVC = [self.delegate viewControllerForPresentingModalView];
    
    // Use the expand modal view controller as the presenting modal if it's being presented.
//    if (self.expandModalViewController.presentingViewController != nil) {
//        return self.expandModalViewController;
//    }
    
    return delegateVC;
}

-(void)nativeCommandWillPresentModalView
{
    [self adWillPresentModalView];
}

-(void)nativeCommandDidDismissModalView
{
    [self adDidDismissModalView];
}

-(void)bridge:(MRBridge *)bridge didFinishLoadingWebView:(UIWebView *)webView
{
    if (self.isAdLoading) {
        
        self.isAdLoading = NO;
        
            // Only tell the delegate that the ad loaded when the view is the default ad view and not a two-part ad view.
            if (bridge == self.mraidBridge) {
                // We do not intialize the javascript/fire ready event, or start our timer for a banner load yet.  We wait until
                // the ad is in the view hierarchy. We are notified by the view when it is potentially added to the hierarchy in
                // -closableView:didMoveToWindow:.
                [self adDidLoad];
            }
        }
}

- (void)bridge:(MRBridge *)bridge didFailLoadingWebView:(UIWebView *)webView error:(NSError *)error
{
    self.isAdLoading = NO;
    
    if (bridge == self.mraidBridge) {
        // We need to report that the ad failed to load when the default ad fails to load.
        [self adDidFailToLoad];
    }
}

-(void)handleNativeCommandCloseWithBridge:(MRBridge *)bridge
{
//     [self close];
}
-(void)bridge:(MRBridge *)bridge performActionForMaxMobSpecificURL:(NSURL *)url
{
//    NSLog(@"MRController - loading MoPub URL: %@", url);
//    MMMoPubHostCommand command = [url mp_mopubHostCommand];
//    if (command == MPMoPubHostCommandPrecacheComplete && self.adRequiresPrecaching) {
//        [self adDidLoad];
//    } else if (command == MPMoPubHostCommandFailLoad) {
//        [self adDidFailToLoad];
//    } else {
//        MPLogWarn(@"MRController - unsupported MoPub URL: %@", [url absoluteString]);
//    }
}
-(void)bridge:(MRBridge *)bridge handleDisplayForDestinationURL:(NSURL *)URL{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandUseCustomClose:(BOOL)useCustomClose{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:(UIInterfaceOrientationMask)forceOrientationMask{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandExpandWithURL:(NSURL *)url useCustomClose:(BOOL)useCuntomClose{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandResizeWithParameters:(NSDictionary *)parameters{
    
}


#pragma mark - <MPClosableViewDelegate>

- (void)closeButtonPressed:(MMClosableView *)view
{
//    [self close];
}

- (void)closableView:(MMClosableView *)closableView didMoveToWindow:(UIWindow *)window
{
    // Fire the ready event and initialize properties if the view has a window.
    MRBridge *bridge = [self bridgeForAdView:closableView];
    
    if (!self.firedReadyEventForDefaultAd && bridge == self.mraidBridge) {
        // The window may be nil if it was removed from a window or added to a view that isn't attached to a window so make sure it actually has a window.
        if (window != nil) {
            // Just in case this code is executed twice, ensures that self is only added as
            // an observer once.
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
            
            //Keep track of the orientation before we start observing changes.
            self.currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
            
            // Placing orientation notification observing here ensures that the controller only
            // observes changes after it's been added to the view hierarchy. Subscribing to
            // orientation changes so we can notify the javascript about the new screen size.
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(orientationDidChange:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil];
            
            [self.adPropertyUpdateTimer scheduleNow];
            [self initializeLoadedAdForBridge:bridge];
            self.firedReadyEventForDefaultAd = YES;
        }
    }
}




#pragma mark - Delegation Wrappers

- (void)adDidLoad
{
    if ([self.delegate respondsToSelector:@selector(adDidLoad:)]) {
        [self.delegate adDidLoad:self.mraidAdView];
    }
}

- (void)adDidFailToLoad
{
    if ([self.delegate respondsToSelector:@selector(adDidFailToLoad:)]) {
        [self.delegate adDidFailToLoad:self.mraidAdView];
    }
}

- (void)adWillClose
{
    if ([self.delegate respondsToSelector:@selector(adWillClose:)]) {
        [self.delegate adWillClose:self.mraidAdView];
    }
}

- (void)adDidClose
{
    if ([self.delegate respondsToSelector:@selector(adDidClose:)]) {
        [self.delegate adDidClose:self.mraidAdView];
    }
}

- (void)adWillPresentModalView
{
    self.modalViewCount++;
    if (self.modalViewCount == 1) {
        [self appShouldSuspend];
    }
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
        [self.delegate appShouldSuspendForAd:self.mraidAdView];
    }
}

- (void)appShouldResume
{
    if ([self.delegate respondsToSelector:@selector(appShouldResumeFromAd:)]) {
        [self.delegate appShouldResumeFromAd:self.mraidAdView];
    }
}



@end
