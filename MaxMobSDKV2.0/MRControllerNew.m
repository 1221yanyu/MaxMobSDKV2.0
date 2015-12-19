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

@interface MRControllerNew () <MRBridgeDelegate>
@property (nonatomic, strong) MRBridge *mraidBridge;
@property (nonatomic, strong) MRAdView *mraidAdView;
@property (nonatomic, assign) NSUInteger modalViewCount;
@end
@implementation MRControllerNew

-(instancetype)initWithAdViewFrame:(CGRect)adViewFrame adPlacementType:(MRAdViewPlacementType)placementType
{
    if (self = [super init]) {
        UIWebView *webView = [self buildMRAIDWebViewWithFrame:adViewFrame];
        _mraidBridge = [[MRBridge alloc] initWithWebView:webView];
        _mraidBridge.delegate = self;
        _mraidBridge.shouldHandleRequests = YES;
        
        _mraidAdView = [[MRAdView alloc] initWithFrame:adViewFrame];
        [_mraidAdView addSubview:webView];
        
        
    }
    return self;
}

- (UIWebView *)buildMRAIDWebViewWithFrame:(CGRect)frame
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
//    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    webView.backgroundColor = [UIColor clearColor];
//    webView.clipsToBounds = YES;
//    webView.opaque = NO;
//    [self mp_setScrollable:NO webView:webView];  //找到所有子视图UIScrollViews或子类和设置他们的滚动和反弹
    
//    if ([webView respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
//        [webView setAllowsInlineMediaPlayback:YES];
//    }
//    
//    if ([webView respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
//        [webView setMediaPlaybackRequiresUserAction:NO];
//    }
    
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
    [self adDidLoad];
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
    [self.delegate adDidLoad:self.mraidAdView];
}

- (void)adDidFailToLoad
{
     [self.delegate adDidFailToLoad:self.mraidAdView];
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
