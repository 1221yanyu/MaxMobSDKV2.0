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
