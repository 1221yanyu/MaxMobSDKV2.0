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

static const NSTimeInterval kAdPropertyUpdateTimerInterval = 1.0;
static const NSTimeInterval kMRAIDResizeAnimationTimeInterval = 0.3;

static NSString *const kMRAIDCommandExpand = @"expand";
static NSString *const kMRAIDCommandResize = @"resize";

@interface MRController () <MRBridgeDelegate>

@property (nonatomic, strong) MRBridge *mraidBridge;
@property (nonatomic, assign) MRAdViewPlacementType placementType;
@property (nonatomic, assign) MRAdViewState currentState;
@property (nonatomic, assign) CGSize currentAdSize;
@property (nonatomic, assign) CGRect mraidDefaultAdFrame;
@property (nonatomic, strong) UIView *resizeBackgroundView;

@property (nonatomic, strong) MMClosableView *mraidAdView;

@property (nonatomic, assign) BOOL isAdLoading;


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

#pragma mark - Public

-(void)loadAdWithConfiguration:(MMAdConfiguration *)configuration
{
    self.isAdLoading = YES;
    
//    NSString *HTML = [configuration adResponseHTMLString];
    NSString *HTML = @"<!DOCTYPE html> <html> <head> <style> body { margin:0; padding:0; overflow:hidden; background:transparent; } </style> <!-- Adgroup is a9b64338add311e281c11231392559e4 --> <script type=\"text/javascript\"> if (trackImpressionHelper == null || typeof(trackImpressionHelper) != \"function\") { function trackImpressionHelper() { var urls = new Array(); var i = 0;  var hiddenSpan = document.createElement('span'); hiddenSpan.style.display = 'none'; var i = 0; for (var i=0;i<urls.length;i++) { var img = document.createElement('img'); img.src = urls[i]; hiddenSpan.appendChild(img); } var body = document.getElementsByTagName('body')[0]; body.appendChild(hiddenSpan); } } </script>  <script type=\"text/javascript\">  if (typeof trackImpressionHelper == 'function') { trackImpressionHelper(); }  function webviewDidAppear() {  }  </script> </head> <body> <style>\r\n#banner {\r\n    position:absolute;\r\n    left:0px;\r\n    top:0px;\r\n    display:block;\r\n    background:#069;\r\n    height:50px;\r\n    width:320px;\r\n    padding:0px;\r\n}\r\n#expa";
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

@end
