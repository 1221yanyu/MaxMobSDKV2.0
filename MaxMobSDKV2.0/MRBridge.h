//
//  MRBridge.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/4.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRConstants.h"


@class MRProperty;
@protocol MRBridgeDelegate;

//SDK与js脚本之间的中间对象
@interface MRBridge : NSObject

@property (nonatomic, assign) BOOL shouldHandleRequests;
@property (nonatomic, weak) id<MRBridgeDelegate> delegate;

-(instancetype)initWithWebView:(UIWebView *)webView;

-(void)loadHTMLString:(NSString *)HTML baseURL:(NSURL *)baseURL;

-(void)fireReadyEvent;

-(void)fireStateChangeEvent:(NSString *)state;

-(void)fireViewableChangeEvent:(BOOL)viewable;

-(void)fireChangeEventForProperty:(MRProperty *)property;
-(void)fireChangeEventsForProperties:(NSArray *)properties;
-(void)fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message;

-(void)fireSizeChangeEvent:(CGSize)size;

-(void)fireSetScreenSize:(CGSize)size;
-(void)fireSetPlacementType:(NSString *)plagementSize;
-(void)fireSetCurrentPositionWithPositionRect:(CGRect)positionRect;
-(void)fireSetDefaultPositionWithPositionRect:(CGRect)positionRect;
-(void)fireSetMaxSize:(CGSize)maxSize;
- (void)fireCommandCompleted:(NSString *)command;
@end


@protocol MRBridgeDelegate <NSObject>

-(BOOL)isLoadingAd;
-(MRAdViewPlacementType)placementType;
-(BOOL)hasUserInteractedWithWebViewForBridge:(MRBridge *)bridge;
-(UIViewController *)viewControllerForPresentingModalView;

-(void)nativeCommandWillPresentModalView;
-(void)nativeCommandDidDismissModalView;

-(void)bridge:(MRBridge *)bridge didFinishLoadingWebView:(UIWebView *)webView;
-(void)bridge:(MRBridge *)bridge didFailLoadingWebView:(UIWebView *)webView error:(NSError *)error;;

-(void)handleNativeCommandCloseWithBridge:(MRBridge *)bridge;
-(void)bridge:(MRBridge *)bridge performActionForMoPubSpecificURL:(NSURL *)url;
-(void)bridge:(MRBridge *)bridge handleDisplayForDestinationURL:(NSURL *)URL;
-(void)bridge:(MRBridge *)bridge handleNativeCommandUseCustomClose:(BOOL)useCustomClose;
-(void)bridge:(MRBridge *)bridge handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:(UIInterfaceOrientationMask)forceOrientationMask;
-(void)bridge:(MRBridge *)bridge handleNativeCommandExpandWithURL:(NSURL *)url useCustomClose:(BOOL)useCustomClose;
-(void)bridge:(MRBridge *)bridge handleNativeCommandResizeWithParameters:(NSDictionary *)parameters;

-(void)bridge:(MRBridge *)bridge handleNativeCommand:(NSString *)command withProperties:(NSDictionary *)properties;

@end