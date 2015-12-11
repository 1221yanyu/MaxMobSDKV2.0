//
//  MRBridge.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/4.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MRBridge.h"
#import "MRBundleManager.h"

static NSString * const kMraidURLScheme = @"mraid";

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
                [self.webView disableJavaScriptDialogs];
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
    MPLogTrace(@"JSON: %@", JSON);
}

-(void)fireChangeEventsForProperties:(NSArray *)properties
{
    NSString *JSON = [NSString stringWithFormat:@"{%@}", [properties componentsJoinedByString:@", "]];
    [self executeJavascript:@"window.mraidbridge.fireChangeEvent(%@);", JSON];
    MPLogTrace(@"JSON: %@", JSON);
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

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSMutableString *urlString = [NSMutableString stringWithString:[url absoluteString]];
    NSString *scheme = url.scheme;
    
    if ([scheme isEqualToString:kMraidURLScheme]) {
        NSLog(@"Trying to process command: %@", urlString);
        NSString *command = url.host;
//        NSDictionary *properties =
        
    }
    
    
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
