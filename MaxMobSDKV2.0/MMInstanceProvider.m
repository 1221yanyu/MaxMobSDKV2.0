//
//  MMInstanceProvider.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/19.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MMInstanceProvider.h"


// MRAID
@class MRController;
@protocol MRControllerDelegate;
@class MMClosableView;
@class MRBridge;
@protocol MRBridgeDelegate;
@protocol MPClosableViewDelegate;
@class MRBundleManager;
@class MRCalendarManager;
@protocol MRCalendarManagerDelegate;
@class EKEventStore;
@class EKEventEditViewController;
@protocol EKEventEditViewDelegate;
@class MRPictureManager;
@protocol MRPictureManagerDelegate;
@class MRImageDownloader;
@protocol MRImageDownloaderDelegate;
@class MRVideoPlayerManager;
@protocol MRVideoPlayerManagerDelegate;
@class MPMoviePlayerViewController;
@class MRNativeCommandHandler;
@protocol MRNativeCommandHandlerDelegate;


@implementation MMInstanceProvider


//#pragma mark - MRAID
//- (MMClosableView *)buildMRAIDMPClosableViewWithFrame:(CGRect)frame webView:(UIWebView *)webView delegate:(id<MPClosableViewDelegate>)delegate;
//- (MRBundleManager *)buildMRBundleManager;
//- (MRController *)buildBannerMRControllerWithFrame:(CGRect)frame delegate:(id<MRControllerDelegate>)delegate;
//- (MRController *)buildInterstitialMRControllerWithFrame:(CGRect)frame delegate:(id<MRControllerDelegate>)delegate;
//- (MRBridge *)buildMRBridgeWithWebView:(UIWebView *)webView delegate:(id<MRBridgeDelegate>)delegate;
//- (UIWebView *)buildUIWebViewWithFrame:(CGRect)frame;
//- (MRCalendarManager *)buildMRCalendarManagerWithDelegate:(id<MRCalendarManagerDelegate>)delegate;
//- (EKEventEditViewController *)buildEKEventEditViewControllerWithEditViewDelegate:(id<EKEventEditViewDelegate>)editViewDelegate;
//- (EKEventStore *)buildEKEventStore;
//- (MRPictureManager *)buildMRPictureManagerWithDelegate:(id<MRPictureManagerDelegate>)delegate;
//- (MRImageDownloader *)buildMRImageDownloaderWithDelegate:(id<MRImageDownloaderDelegate>)delegate;
//- (MRVideoPlayerManager *)buildMRVideoPlayerManagerWithDelegate:(id<MRVideoPlayerManagerDelegate>)delegate;
//- (MPMoviePlayerViewController *)buildMPMoviePlayerViewControllerWithURL:(NSURL *)URL;
//- (MRNativeCommandHandler *)buildMRNativeCommandHandlerWithDelegate:(id<MRNativeCommandHandlerDelegate>)delegate;

@end
