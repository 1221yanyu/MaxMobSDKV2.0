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
#import "UIView+MPAdditions.h"
#import "UIWebView+MPAdditions.h"
#import "NSHTTPURLResponse+MPAdditions.h"
#import "NSURL+MPAdditions.h"
#import "MPTimer.h"
#import "MPGlobal.h"
#import "MRExpandModalViewController.h"
static const NSTimeInterval kAdPropertyUpdateTimerInterval = 100.0;
static const NSTimeInterval kMRAIDResizeAnimationTimeInterval = 0.3;

static NSString *const kMRAIDCommandExpand = @"expand";
static NSString *const kMRAIDCommandResize = @"resize";

@interface MRController () <MRBridgeDelegate,MMClosableViewDelegate>

@property (nonatomic, strong) MRBridge *mraidBridge;
@property (nonatomic, strong) MRBridge *mraidBridgeTwoPart;
@property (nonatomic, assign) MRAdViewPlacementType placementType;
@property (nonatomic, assign) MRAdViewState currentState;
@property (nonatomic, assign) CGSize currentAdSize;
@property (nonatomic, assign) CGRect mraidDefaultAdFrame;
@property (nonatomic, strong) UIView *resizeBackgroundView;
@property (nonatomic, assign) NSUInteger modalViewCount;
@property (nonatomic, assign) BOOL firedReadyEventForDefaultAd;       
@property (nonatomic, strong) MPTimer *adPropertyUpdateTimer;
@property (nonatomic, assign) BOOL isAnimatingAdSize;
@property (nonatomic, weak) UIView *originalSuperview;
@property (nonatomic, assign) BOOL isViewable;
@property (nonatomic, strong) NSMutableData *twoPartExpandData;
@property (nonatomic, assign) NSStringEncoding responseEncoding;
@property (nonatomic, assign) BOOL adRequiresPrecaching;
@property (nonatomic, assign) BOOL isAdVastVideoPlayer;
@property (nonatomic, assign) CGRect mraidDefaultAdFrameInKeyWindow;


@property (nonatomic, strong) MMClosableView *mraidAdView;
@property (nonatomic, strong) MMClosableView *mraidAdViewTwoPart;


@property (nonatomic, strong) MRExpandModalViewController *expandModalViewController;
//@property (nonatomic, strong) MPAdDestinationDisplayAgent *destinationDisplayAgent;




@property (nonatomic, strong) id<MPAdAlertManagerProtocol> adAlertManager;
@property (nonatomic, strong) id<MPAdAlertManagerProtocol> adAlertManagerTwoPart;

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
        _forceOrientationMask = UIInterfaceOrientationMaskAll;
        _isAnimatingAdSize = NO;
        _firedReadyEventForDefaultAd = NO;
        _currentAdSize = CGSizeZero;
        
        _mraidDefaultAdFrame = adViewFrame;
        
        _adPropertyUpdateTimer = [MPTimer timerWithTimeInterval:kAdPropertyUpdateTimerInterval target:self selector:@selector(updateMRAIDProperties) repeats:YES];
        
        _adPropertyUpdateTimer.runLoopMode = NSRunLoopCommonModes;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewEnteredBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        _resizeBackgroundView = [[UIView alloc]initWithFrame:adViewFrame];
        _resizeBackgroundView.backgroundColor = [UIColor clearColor];
        
        UIWebView *webView = [self buildMRAIDWebViewWithFrame:adViewFrame];
        
        _mraidBridge = [[MRBridge alloc] initWithWebView:webView];
        _mraidBridge.delegate = self;
        _mraidBridge.shouldHandleRequests = YES;
        
//        _destinationDisplayAgent = [[MPCoreInstanceProvider sharedProvider] buildMPAdDestinationDisplayAgentWithDelegate:self];
        
        _mraidAdView = [[MMClosableView alloc]initWithFrame:adViewFrame closeButtonType:MMClosableViewCloseButtonTypeTappableWithImage];
        _mraidAdView.delegate = self;
        _mraidAdView.clipsToBounds = YES;
        webView.frame = _mraidAdView.bounds;
        [_mraidAdView addSubview:webView];
        
        if (placementType == MRAdViewPlacementTypeInterstitial) {
            _mraidAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        
        _adAlertManager = [self buildMPAdAlertManagerWithDelegate:self];
        _adAlertManagerTwoPart = [self buildMPAdAlertManagerWithDelegate:self];
    }
    return self;
}

-(void)dealloc
{
    [_adPropertyUpdateTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - CoreInstanceProvider
- (id<MPAdAlertManagerProtocol>)buildMPAdAlertManagerWithDelegate:(id)delegate
{
    id<MPAdAlertManagerProtocol> adAlertManager = nil;
    
    Class adAlertManagerClass = NSClassFromString(@"MPAdAlertManager");
    if (adAlertManagerClass != nil) {
        adAlertManager = [[adAlertManagerClass alloc] init];
        [adAlertManager performSelector:@selector(setDelegate:) withObject:delegate];
    }
    
    return adAlertManager;
}

#pragma mark - Public

-(void)loadAdWithConfiguration:(MMAdConfiguration *)configuration
{
    self.isAdLoading = YES;
    
    [self initAdAlertManager:self.adAlertManager forAdView:self.mraidAdView];

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
    self.mraidBridgeTwoPart.shouldHandleRequests = YES;
    // If orientation has been forced while requests are disabled (during animation), we need to execute that command through the block forceOrientationAfterAnimationBlock() after the presentation completes.
    if (self.forceOrientationAfterAnimationBlock) {
        self.forceOrientationAfterAnimationBlock();
        self.forceOrientationAfterAnimationBlock = nil;
    }
}

- (void)disableRequestHandling
{
    self.mraidBridge.shouldHandleRequests = NO;
    self.mraidBridgeTwoPart.shouldHandleRequests = NO;
//    [self.destinationDisplayAgent cancel];
}

#pragma mark - Loading Two Part Expand (NSURLConnectionDelegate)

- (void)loadTwoPartCreativeFromURL:(NSURL *)url
{
    self.isAdLoading = YES;
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
    if (connection) {
        self.twoPartExpandData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.twoPartExpandData setLength:0];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSDictionary *headers = [httpResponse allHeaderFields];
    NSString *contentType = [headers objectForKey:kMoPubHTTPHeaderContentType];
    self.responseEncoding = [httpResponse stringEncodingFromContentType:contentType];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.twoPartExpandData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isAdLoading = NO;
    // No matter what, show the close button on the expanded view.
    self.expansionContentView.closeButtonType = MMClosableViewCloseButtonTypeTappableWithImage;
    [self.mraidBridge fireErrorEventForAction:kMRAIDCommandExpand withMessage:@"Could not load URL."];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *str = [[NSString alloc] initWithData:self.twoPartExpandData encoding:self.responseEncoding];
    [self.mraidBridgeTwoPart loadHTMLString:str baseURL:connection.currentRequest.URL];
}

#pragma mark - Private
- (void)initAdAlertManager:(id<MPAdAlertManagerProtocol>)adAlertManager forAdView:(MMClosableView *)adView
{
    adAlertManager.adConfiguration = [self.delegate adConfiguration];
    adAlertManager.adUnitId = [self.delegate adUnitId];
    adAlertManager.targetAdView = adView;
    adAlertManager.location = [self.delegate location];
    [adAlertManager beginMonitoringAlerts];
}

- (MMClosableView *)adViewForBridge:(MRBridge *)bridge
{
    if (bridge == self.mraidBridgeTwoPart) {
        return self.mraidAdViewTwoPart;
    }
    
    return self.mraidAdView;
}

- (MRBridge *)bridgeForAdView:(MMClosableView *)view
{
    if (view == self.mraidAdViewTwoPart) {
        return self.mraidBridgeTwoPart;
    }
    
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


#pragma mark - Orientation Notifications

- (void)orientationDidChange:(NSNotification *)notification
{
    // We listen for device notification changes because at that point our ad's frame is in
    // the correct state; however, MRAID updates should only happen when the interface changes, so the update logic is only executed if the interface orientation has changed.
    
    //MPInterfaceOrientation is guaranteed to be the new orientation at this point.
    UIInterfaceOrientation newInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (newInterfaceOrientation != self.currentInterfaceOrientation) {
        // Update all properties and fire a size change event.
        [self updateMRAIDProperties];
        
        //According to MRAID Specs, a resized ad should close when there's an orientation change
        //due to unpredictability of the new layout.
        if (self.currentState == MRAdViewStateResized) {
//            [self close];
        }
        
        self.currentInterfaceOrientation = newInterfaceOrientation;
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
            visibleFrame = self.expansionContentView.frame;
        } else {
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            visibleFrame = [self.mraidAdView.superview convertRect:self.mraidAdView.frame toView:keyWindow.rootViewController.view];
        }
    } else if (self.placementType == MRAdViewPlacementTypeInterstitial) {
        visibleFrame = self.mraidAdView.frame;
    }
    
    return visibleFrame;
}

- (CGRect)defaultAdFrameInScreenSpace
{
    CGRect defaultFrame = CGRectZero;
    
    if (self.placementType == MRAdViewPlacementTypeInline) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
//        if (self.expansionContentView == self.mraidAdViewTwoPart) {
//            defaultFrame = [self.mraidAdView.superview convertRect:self.mraidAdView.frame toView:keyWindow.rootViewController.view];
//        } else {
            defaultFrame = [self.originalSuperview convertRect:self.mraidDefaultAdFrame toView:keyWindow.rootViewController.view];
//        }
    } else if (self.placementType == MRAdViewPlacementTypeInterstitial) {
        defaultFrame = self.mraidAdView.frame;
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
//    [self.mraidBridgeTwoPart fireSetDefaultPositionWithPositionRect:defaultFrame];
    
    NSLog(@"Default Position: %@", NSStringFromCGRect(defaultFrame));
}

- (void)updateScreenSize
{
    // Fire an event for screen size changing. This includes the area of the status bar in its calculation.
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    // Fire to both ad views as it pertains to both views.
    [self.mraidBridge fireSetScreenSize:screenSize];
//    [self.mraidBridgeTwoPart fireSetScreenSize:screenSize];
    
    NSLog(@"Screen Size: %@", NSStringFromCGSize(screenSize));
}

- (void)updateMaxSize
{
    // Similar to updateScreenSize except this doesn't include the area of the status bar in its calculation.
    CGSize maxSize = [UIScreen mainScreen].bounds.size;
    
    // Fire to both ad views as it pertains to both views.
    [self.mraidBridge fireSetMaxSize:maxSize];
//    [self.mraidBridgeTwoPart fireSetMaxSize:maxSize];
    
    NSLog(@"Max Size: %@", NSStringFromCGSize(maxSize));
}


#pragma mark - MRAID events

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

- (void)changeStateTo:(MRAdViewState)state
{
    self.currentState = state;
    
    // Update the mraid properties so they're ready before the state change happens.
    [self updateMRAIDProperties];
    [self fireChangeEventToBothBridgesForProperty:[MRStateProperty propertyWithState:self.currentState]];
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

#pragma mark - Viewability Helpers

- (void)checkViewability
{
    BOOL viewable = MPViewIsVisible([self activeView]) &&
    ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive);
    [self updateViewabilityWithBool:viewable];
}


- (void)viewEnteredBackground
{
    [self updateViewabilityWithBool:NO];
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

#pragma mark - Expand Helpers

- (void)presentExpandModalViewControllerWithView:(MMClosableView *)view animated:(BOOL)animated
{
    [self presentExpandModalViewControllerWithView:view animated:animated completion:nil];
}

- (void)presentExpandModalViewControllerWithView:(MMClosableView *)view animated:(BOOL)animated completion:(void (^)())completionBlock
{
    [self willBeginAnimatingAdSize];
    
    self.expandModalViewController = [[MRExpandModalViewController alloc] initWithOrientationMask:self.forceOrientationMask];
    [self.expandModalViewController.view addSubview:view];
    view.frame = self.expandModalViewController.view.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.expandModalViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.expandModalViewController hideStatusBar];
    
    [[self.delegate viewControllerForPresentingModalView] presentViewController:self.expandModalViewController
                                                                       animated:animated
                                                                     completion:^{
                                                                         self.currentInterfaceOrientation = MPInterfaceOrientation();
                                                                         [self didEndAnimatingAdSize];
                                                                         
                                                                         if (completionBlock) {
                                                                             completionBlock();
                                                                         }
                                                                     }];
}

- (void)willBeginAnimatingAdSize
{
    self.isAnimatingAdSize = YES;
    [self disableRequestHandling];
}

- (void)didEndAnimatingAdSize
{
    self.isAnimatingAdSize = NO;
    [self enableRequestHandling];
}


#pragma mark - Resize Helpers

- (CGRect)adjustedFrameForFrame:(CGRect)frame allowOffscreen:(BOOL)allowOffscreen
{
    if (allowOffscreen) {
        return frame;
    }
    
    CGRect applicationFrame = MPApplicationFrame();
    CGFloat applicationWidth = CGRectGetWidth(applicationFrame);
    CGFloat applicationHeight = CGRectGetHeight(applicationFrame);
    CGFloat adFrameWidth = CGRectGetWidth(frame);
    CGFloat adFrameHeight = CGRectGetHeight(frame);
    
    //Checking that the ad's frame falls offscreen, and then it is smaller than the screen's bounds (so when
    //moved onscreen, it will fit). If not, we bail out, and validation is done separately.
    if (!CGRectContainsRect(applicationFrame, frame) && adFrameWidth <= applicationWidth && adFrameHeight <= applicationHeight) {
        
        CGFloat applicationMinX = CGRectGetMinX(applicationFrame);
        CGFloat applicationMaxX = CGRectGetMaxX(applicationFrame);
        CGFloat adFrameMinX = CGRectGetMinX(frame);
        CGFloat adFrameMaxX = CGRectGetMaxX(frame);
        
        if (adFrameMinX < applicationMinX) {
            frame.origin.x += applicationMinX - adFrameMinX;
        } else if (adFrameMaxX > applicationMaxX) {
            frame.origin.x -= adFrameMaxX - applicationMaxX;
        }
        
        CGFloat applicationMinY = CGRectGetMinY(applicationFrame);
        CGFloat applicationMaxY = CGRectGetMaxY(applicationFrame);
        CGFloat adFrameMinY = CGRectGetMinY(frame);
        CGFloat adFrameMaxY = CGRectGetMaxY(frame);
        
        if (adFrameMinY < applicationMinY) {
            frame.origin.y += applicationMinY - adFrameMinY;
        } else if (adFrameMaxY > applicationMaxY) {
            frame.origin.y -= adFrameMaxY - applicationMaxY;
        }
    }
    
    return frame;
}

- (BOOL)isValidResizeFrame:(CGRect)frame allowOffscreen:(BOOL)allowOffscreen
{
    BOOL valid = YES;
    if (!allowOffscreen && !CGRectContainsRect(MPApplicationFrame(), frame)) {
        valid = NO;
    } else if (CGRectGetWidth(frame) < 50.0f || CGRectGetHeight(frame) < 50.0f) {
        valid = NO;
    }
    
    return valid;
}

- (BOOL)isValidResizeCloseButtonPlacementInFrame:(CGRect)newFrame
{
    CGRect closeButtonFrameForResize = MMClosableViewCustomCloseButtonFrame(newFrame.size, self.mraidAdView.closeButtonLocation);
    //Manually calculating Button's Frame in the window (newFrame's soon-to-be superview) because newFrame is not
    //part of the view hierarchy yet.
    CGRect closeButtonFrameInWindow = CGRectOffset(closeButtonFrameForResize, CGRectGetMinX(newFrame), CGRectGetMinY(newFrame));
    
    return CGRectContainsRect(MPApplicationFrame(), closeButtonFrameInWindow);
}

- (MMClosableViewCloseButtonLocation)adCloseButtonLocationFromString:(NSString *)closeButtonLocationString
{
    if ([closeButtonLocationString isEqualToString:@"top-left"]) {
        return MMClosableViewCloseButtonLocationTopLeft;
    } else if ([closeButtonLocationString isEqualToString:@"top-center"]) {
        return MMClosableViewCloseButtonLocationTopCenter;
    } else if ([closeButtonLocationString isEqualToString:@"bottom-left"]) {
        return MMClosableViewCloseButtonLocationBottomLeft;
    } else if ([closeButtonLocationString isEqualToString:@"bottom-center"]) {
        return MMClosableViewCloseButtonLocationBottomCenter;
    } else if ([closeButtonLocationString isEqualToString:@"bottom-right"]) {
        return MMClosableViewCloseButtonLocationBottomRight;
    } else if ([closeButtonLocationString isEqualToString:@"center"]) {
        return MMClosableViewCloseButtonLocationCenter;
    } else {
        return MMClosableViewCloseButtonLocationTopRight;
    }
}

- (void)animateViewFromDefaultStateToResizedState:(MMClosableView *)view withFrame:(CGRect)newFrame
{
    [self willBeginAnimatingAdSize];
    
    [UIView animateWithDuration:kMRAIDResizeAnimationTimeInterval animations:^{
        self.mraidAdView.frame = newFrame;
    } completion:^(BOOL finished) {
        [self changeStateTo:MRAdViewStateResized];
        [self didEndAnimatingAdSize];
    }];
}

#pragma mark - Close Helpers

- (void)close
{
    switch (self.currentState) {
        case MRAdViewStateDefault:
            [self closeFromDefaultState];
            break;
        case MRAdViewStateExpanded:
            [self closeFromExpandedState];
            break;
        case MRAdViewStateResized:
            [self closeFromResizedState];
            break;
        case MRAdViewStateHidden:
            break;
        default:
            break;
    }
}

- (void)closeFromDefaultState
{
    [self adWillClose];
    
    self.mraidAdView.hidden = YES;
    [self changeStateTo:MRAdViewStateHidden];
    
    [self adDidClose];
}

- (void)closeFromExpandedState
{
    self.mraidAdView.closeButtonType = MMClosableViewCloseButtonTypeNone;
    
    // Immediately re-parent the ad so it will show up as the expand modal goes away rather than after.
    [self.originalSuperview addSubview:self.mraidAdView];
    self.mraidAdView.frame = self.mraidDefaultAdFrame;
    if (self.placementType != MRAdViewPlacementTypeInterstitial) {
        self.mraidAdView.autoresizingMask = UIViewAutoresizingNone;
    }
    
    // Track isAnimatingAdSize because we have a timer that will update the mraid ad properties. We don't want to examine our views when
    // they're in a transitional state.
    [self willBeginAnimatingAdSize];
    
    // Tell the modal view controller to restore the state of the status bar back to what the application had it set to.
    [self.expandModalViewController restoreStatusBarVisibility];
    __weak __typeof__(self) weakSelf = self;
    [self.expandModalViewController dismissViewControllerAnimated:YES completion:^{
        __typeof__(self) strongSelf = weakSelf;
        
        
        [strongSelf didEndAnimatingAdSize];
        [strongSelf adDidDismissModalView];
        
        // Get rid of the bridge and view if we are closing from two-part expand.
        if (strongSelf.mraidAdViewTwoPart) {
            [strongSelf.adAlertManagerTwoPart endMonitoringAlerts];
            strongSelf.mraidAdViewTwoPart = nil;
            strongSelf.mraidBridgeTwoPart = nil;
        }
        
        strongSelf.expansionContentView = nil;
        strongSelf.expandModalViewController = nil;
        
        // Waiting this long to change the state results in some awkward animation. The full screen ad will briefly appear in the banner's
        // frame after the modal dismisses. However, this is a much safer time to change the state and results in less side effects.
        [strongSelf changeStateTo:MRAdViewStateDefault];
    }];
}

- (void)closeFromResizedState
{
    self.mraidAdView.closeButtonType = MMClosableViewCloseButtonTypeNone;
    
    [self willBeginAnimatingAdSize];
    
    [UIView animateWithDuration:kMRAIDResizeAnimationTimeInterval animations:^{
        self.mraidAdView.frame = self.mraidDefaultAdFrameInKeyWindow;
    } completion:^(BOOL finished) {
        [self.resizeBackgroundView removeFromSuperview];
        [self.originalSuperview addSubview:self.mraidAdView];
        self.mraidAdView.frame = self.mraidDefaultAdFrame;
        [self changeStateTo:MRAdViewStateDefault];
        [self didEndAnimatingAdSize];
        [self adDidDismissModalView];
    }];
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
    if (self.expandModalViewController.presentingViewController != nil) {
        return self.expandModalViewController;
    }
    
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
            }else if (bridge == self.mraidBridgeTwoPart) {
                // If the default ad was already viewable, we need to simply tell the two part it is viewable. Otherwise, if the default
                // ad wasn't viewable, we need to update the state across both webviews and the controller.
                if (self.isViewable) {
                    [self.mraidBridgeTwoPart fireChangeEventForProperty:[MRViewableProperty propertyWithViewable:YES]];
                } else {
                    [self updateViewabilityWithBool:YES];
                }
                
                // We initialize javascript and fire the ready event for the two part ad view once it loads
                // since it'll already be in the view hierarchy.
                [self initializeLoadedAdForBridge:bridge];
            }
        }
}

- (void)bridge:(MRBridge *)bridge didFailLoadingWebView:(UIWebView *)webView error:(NSError *)error
{
    self.isAdLoading = NO;
    
    if (bridge == self.mraidBridge) {
        // We need to report that the ad failed to load when the default ad fails to load.
        [self adDidFailToLoad];
    } else if (bridge == self.mraidBridgeTwoPart) {
        // Always show the close button when the two-part expand fails.
        self.expansionContentView.closeButtonType = MMClosableViewCloseButtonTypeTappableWithImage;
        
        // For two-part expands, we don't want to tell the delegate anything went wrong since the ad did successfully load.
        // We will fire an error to the javascript though.
        [self.mraidBridge fireErrorEventForAction:kMRAIDCommandExpand withMessage:@"Could not load URL."];
    }
}

-(void)handleNativeCommandCloseWithBridge:(MRBridge *)bridge
{
//     [self close];
}
-(void)bridge:(MRBridge *)bridge performActionForMaxMobSpecificURL:(NSURL *)url
{
    NSLog(@"MRController - loading MoPub URL: %@", url);
    MPMoPubHostCommand command = [url mp_mopubHostCommand];
    if (command == MPMoPubHostCommandPrecacheComplete && self.adRequiresPrecaching) {
        [self adDidLoad];
    } else if (command == MPMoPubHostCommandFailLoad) {
        [self adDidFailToLoad];
    } else {
        NSLog(@"MRController - unsupported MoPub URL: %@", [url absoluteString]);
    }
}
-(void)bridge:(MRBridge *)bridge handleDisplayForDestinationURL:(NSURL *)URL{
    if ([self hasUserInteractedWithWebViewForBridge:bridge]) {
//        [self.destinationDisplayAgent displayDestinationForURL:URL];
    }
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandUseCustomClose:(BOOL)useCustomClose{
    if (self.placementType != MRAdViewPlacementTypeInterstitial) {
        return;
    }
    
    [self configureCloseButtonForView:self.mraidAdView forUseCustomClose:useCustomClose];
}
- (void)configureCloseButtonForView:(MMClosableView *)view forUseCustomClose:(BOOL)useCustomClose
{
    if (useCustomClose) {
        // When using custom close, we must leave a tappable region on the screen and just hide the image
        // unless the ad is a vast video ad. For vast video, we expect that the creative will have a tappable
        // close region.
        if (self.isAdVastVideoPlayer) {
            view.closeButtonType = MMClosableViewCloseButtonTypeNone;
        } else {
            view.closeButtonType = MMClosableViewCloseButtonTypeTappableWithoutImage;
        }
    } else {
        // When not using custom close, show our own image with a tappable region.
        view.closeButtonType = MMClosableViewCloseButtonTypeTappableWithImage;
    }
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:(UIInterfaceOrientationMask)forceOrientationMask{
    
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandExpandWithURL:(NSURL *)url useCustomClose:(BOOL)useCustomClose{
    if (self.placementType != MRAdViewPlacementTypeInline) {
        [bridge fireErrorEventForAction:kMRAIDCommandExpand withMessage:@"Cannot expand from interstitial ads."];
        return;
    }
    
    // Save the state of the default ad view if it's in default state. If it's resized, the controller has already
    // been informed of a modal being presented on resize, and the expand basically takes its place. Additionally,
    // self.mraidDefaultAdFrame has already been set from resize, and the mraidAdView's frame is not the correct default.
    if (self.currentState != MRAdViewStateResized) {
        self.mraidDefaultAdFrame = self.mraidAdView.frame;
        [self adWillPresentModalView];
    } else {
        [self.resizeBackgroundView removeFromSuperview];
    }
    
    // We change the state after the modal is fully presented which results in an undesirable animation where the banner will briefly appear in the modal which then
    // will instantly change to the full screen ad.  However, it is far safer to update the state like this and has less side effects.
    if (url) {
        // It doesn't matter what frame we use for the two-part expand. We'll overwrite it with a new frame when presenting the modal.
        CGRect twoPartFrame = self.mraidAdView.frame;
        
        UIWebView *twoPartWebView = [self buildMRAIDWebViewWithFrame:twoPartFrame];
        self.mraidBridgeTwoPart = [[MRBridge alloc] initWithWebView:twoPartWebView];
        self.mraidBridgeTwoPart = self;
        self.mraidBridgeTwoPart.shouldHandleRequests = YES;
        
        self.mraidAdViewTwoPart =[[MMClosableView alloc] initWithFrame:twoPartFrame closeButtonType:MMClosableViewCloseButtonTypeTappableWithImage];
        self.mraidAdViewTwoPart = self;
        self.mraidAdViewTwoPart.clipsToBounds = YES;
        twoPartWebView.frame = self.mraidAdViewTwoPart.bounds;
        [self.mraidAdViewTwoPart addSubview:twoPartWebView];
        
        self.isAdLoading = YES;
        
        self.expansionContentView = self.mraidAdViewTwoPart;
        
        // To avoid race conditions, we start loading the two part creative after the ad has fully expanded.
        [self presentExpandModalViewControllerWithView:self.expansionContentView animated:YES completion:^{
            [self initAdAlertManager:self.adAlertManagerTwoPart forAdView:self.mraidAdViewTwoPart];
            [self loadTwoPartCreativeFromURL:url];
            [self changeStateTo:MRAdViewStateExpanded];
        }];
    } else {
        self.expansionContentView = self.mraidAdView;
        //If the ad is resized, the original superview has already been set.
        if (self.currentState != MRAdViewStateResized) {
            self.originalSuperview = self.mraidAdView.superview;
        }
        [self presentExpandModalViewControllerWithView:self.expansionContentView animated:YES completion:^{
            [self changeStateTo:MRAdViewStateExpanded];
        }];
    }
    
    [self configureCloseButtonForView:self.expansionContentView forUseCustomClose:useCustomClose];
}
-(void)bridge:(MRBridge *)bridge handleNativeCommandResizeWithParameters:(NSDictionary *)parameters{
    NSArray *parameterKeys = [parameters allKeys];
    if (self.currentState == MRAdViewStateExpanded) {
        [bridge fireErrorEventForAction:kMRAIDCommandResize withMessage:@"Cannot resize from and expanded state."];
        return;
    } else if (self.placementType != MRAdViewPlacementTypeInline) {
        [bridge fireErrorEventForAction:kMRAIDCommandResize withMessage:@"Cannot resize from interstitial ads."];
        return;
    } else if (![parameterKeys containsObject:@"width"] || ![parameterKeys containsObject:@"height"] || ![parameterKeys containsObject:@"offsetX"] || ![parameterKeys containsObject:@"offsetY"]) {
        [bridge fireErrorEventForAction:kMRAIDCommandResize withMessage:@"Cannot resize when missing required parameter(s)."];
        return;
    }
    
    CGFloat width = [[parameters objectForKey:@"width"] floatValue];
    CGFloat height = [[parameters objectForKey:@"height"] floatValue];
    CGFloat offsetX = [[parameters objectForKey:@"offsetX"] floatValue];
    CGFloat offsetY = [[parameters objectForKey:@"offsetY"] floatValue];
    BOOL allowOffscreen = [parameters objectForKey:@"allowOffscreen"] ? [[parameters objectForKey:@"allowOffscreen"] boolValue] : YES;
    NSString *customClosePositionString = [[parameters objectForKey:@"customClosePosition"] length] ? [parameters objectForKey:@"customClosePosition"] : @"top-right";
    
    //save default frame of the ad view
    if (self.currentState == MRAdViewStateDefault) {
        self.mraidDefaultAdFrameInKeyWindow = [self.mraidAdView.superview convertRect:self.mraidAdView.frame toView:MPKeyWindow().rootViewController.view];
    }
    
    CGRect newFrame = CGRectMake(CGRectGetMinX(self.mraidDefaultAdFrameInKeyWindow) + offsetX, CGRectGetMinY(self.mraidDefaultAdFrameInKeyWindow) + offsetY, width, height);
    newFrame = [self adjustedFrameForFrame:newFrame allowOffscreen:allowOffscreen];
    
    self.mraidAdView.closeButtonType = MMClosableViewCloseButtonTypeTappableWithoutImage;
    self.mraidAdView.closeButtonLocation = [self adCloseButtonLocationFromString:customClosePositionString];
    
    if (![self isValidResizeFrame:newFrame allowOffscreen:allowOffscreen]) {
        [self.mraidBridge fireErrorEventForAction:kMRAIDCommandResize withMessage:@"Could not display desired frame in compliance with MRAID 2.0 specifications."];
    } else if (![self isValidResizeCloseButtonPlacementInFrame:newFrame]) {
        [self.mraidBridge fireErrorEventForAction:kMRAIDCommandResize withMessage:@"Custom close event region is offscreen."];
    } else {
        // If current state is default, save our current frame as the default frame, set originalSuperview, setup resizeBackgroundView,
        // move mraidAdView to rootViewController's view, and call adWillPresentModalView
        if (self.currentState == MRAdViewStateDefault) {
            self.mraidDefaultAdFrame = self.mraidAdView.frame;
            self.originalSuperview = self.mraidAdView.superview;
            
            self.mraidAdView.frame = self.mraidDefaultAdFrameInKeyWindow;
            self.resizeBackgroundView.frame = MPApplicationFrame();
            
            [MPKeyWindow().rootViewController.view addSubview:self.resizeBackgroundView];
            [MPKeyWindow().rootViewController.view addSubview:self.mraidAdView];
            
            [self adWillPresentModalView];
        }
        
        [self animateViewFromDefaultStateToResizedState:self.mraidAdView withFrame:newFrame];
    }
}


#pragma mark - <MPClosableViewDelegate>

- (void)closeButtonPressed:(MMClosableView *)view
{
    [self close];
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
