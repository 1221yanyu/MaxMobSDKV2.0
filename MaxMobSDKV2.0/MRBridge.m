//
//  MRBridge.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/4.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MRBridge.h"
#import "MRBundleManager.h"
#import "UIWebView+MMAdditions.h"

static NSString * const kMraidURLScheme = @"mraid";
NSString *const kJavaScriptDisableDialogSnippet = @"window.alert = function() { }; window.prompt = function() { }; window.confirm = function() { };";


@interface MRBridge () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
//@property (nonatomic, strong)

@end

@implementation MRBridge

-(instancetype)initWithWebView:(UIWebView *)webView
{
    if (self = [super init]) {
        _webView = webView;
        _webView.delegate = self;
        
    }
    return  self;
}

-(void)dealloc
{
    _webView.delegate = nil;
}

-(void)loadHTMLString:(NSString *)HTML baseURL:(NSURL *)baseURL
{
    if (![self MRAIDScriptPath]) {
        NSLog(@"can't locate mraid.js");
        return;
    }
    if (HTML) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Execute the javascript in the web view directly.
            NSString *mraidString = [NSString stringWithContentsOfFile:[self MRAIDScriptPath] encoding:NSUTF8StringEncoding error:nil];
            
            // Once done loading from the file, execute the javascript and load the html into the web view.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self executeJavascript:mraidString];
//                [self.webView disableJavaScriptDialogs];
                [self.webView loadHTMLString:HTML baseURL:baseURL];

            });
        });
    }
}

-(void)fireReadyEvent
{
    [self executeJavascript:@"window.mraidbridge.fireReadyEvent();"];
}

-(void)fireChangeEventForProperty:(MRProperty *)property
{
    NSString *JSON = [NSString stringWithFormat:@"{%@}", property];
    [self executeJavascript:@"window.mraidbridge.fireChangeEvent(%@);", JSON];
//    MPLogTrace(@"JSON: %@", JSON);
}

-(void)fireChangeEventsForProperties:(NSArray *)properties
{
    NSString *JSON = [NSString stringWithFormat:@"{%@}", [properties componentsJoinedByString:@", "]];
    [self executeJavascript:@"window.mraidbridge.fireChangeEvent(%@);", JSON];
//    MPLogTrace(@"JSON: %@", JSON);
}

-(void)fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message
{
    [self executeJavascript:@"window.mraidbridge.fireErrorEvent('%@', '%@');", message, action];
}

-(void)fireSizeChangeEvent:(CGSize)size
{
    [self executeJavascript:@"window.mraidbridge.notifySizeChangeEvent(%.1f, %.1f);", size.width, size.height];
}

-(void)fireSetScreenSize:(CGSize)size
{
    [self executeJavascript:@"window.mraidbridge.setScreenSize(%.1f, %.1f);", size.width, size.height];
}

-(void)fireSetPlacementType:(NSString *)placementType
{
    [self executeJavascript:@"window.mraidbridge.setPlacementType('%@');", placementType];
}

-(void)fireSetCurrentPositionWithPositionRect:(CGRect)positionRect
{
    [self executeJavascript:@"window.mraidbridge.setCurrentPosition(%.1f, %.1f, %.1f, %.1f);", positionRect.origin.x, positionRect.origin.y,
     positionRect.size.width, positionRect.size.height];
}

-(void)fireSetDefaultPositionWithPositionRect:(CGRect)positionRect
{
    [self executeJavascript:@"window.mraidbridge.setDefaultPosition(%.1f, %.1f, %.1f, %.1f);", positionRect.origin.x, positionRect.origin.y,
     positionRect.size.width, positionRect.size.height];
}

-(void)fireSetMaxSize:(CGSize)maxSize
{
    [self executeJavascript:@"window.mraidbridge.setMaxSize(%.1f, %.1f);", maxSize.width, maxSize.height];
}



#pragma mark - <UIWebViewDelegate>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSMutableString *urlString = [NSMutableString stringWithString:[url absoluteString]];
    NSString *scheme = url.scheme;
    
    
    if (!self.shouldHandleRequests) {
        return NO;
    }
    
    BOOL isLoading = [self.delegate isLoadingAd];
    BOOL userInteractedWithWebView = [self.delegate hasUserInteractedWithWebViewForBridge:self];
    BOOL safeToAutoloadLink = navigationType == UIWebViewNavigationTypeLinkClicked || userInteractedWithWebView;
    
    if (!isLoading && (navigationType == UIWebViewNavigationTypeOther || navigationType == UIWebViewNavigationTypeLinkClicked)) {
        BOOL iframe = ![request.URL isEqual:request.mainDocumentURL];
        
        // If we load a URL from an iFrame that did not originate from a click or
        // is a deep link, handle normally and return safeToAutoloadLink.
        if (iframe && !((navigationType == UIWebViewNavigationTypeLinkClicked) && ([scheme isEqualToString:@"https"] || [scheme isEqualToString:@"http"]))) {
            return safeToAutoloadLink;
        }
        
        // Otherwise, open the URL in a new web view.
        [self.delegate bridge:self handleDisplayForDestinationURL:url];
        return NO;
    }
    
    return safeToAutoloadLink;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [webView disableJavaScriptDialogs];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate bridge:self didFinishLoadingWebView:webView];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    [self.delegate bridge:self didFailLoadingWebView:webView error:error];
}
    



#pragma mark - Private

-(NSString *)MRAIDScriptPath
{
    MRBundleManager *bundleManager = [MRBundleManager sharedManager];
    return [bundleManager mraidPath];
}

-(void)executeJavascript:(NSString *)javascript, ...
{
    va_list args;
    va_start(args, javascript);
    [self executeJavascript:javascript withVarArgs:args];
    va_end(args);
}

-(void)fireNativeCommandCompleteEvent:(NSString *)command
{
    [self executeJavascript:@"window.mraidbridge.nativeCallComplete('%@');", command];
}

-(void)executeJavascript:(NSString *)javascript withVarArgs:(va_list)args
{
    NSString *js = [[NSString alloc] initWithFormat:javascript arguments:args];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

@end
