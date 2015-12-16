//
//  ViewController.m
//  testAd
//
//  Created by Jacob on 15/12/10.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "ViewController.h"
#import "MRController.h"
#import "MRBridge.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect adFrame = CGRectMake(0, 0, 320, 50);
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:adFrame];
    MMAdConfiguration *configuration;
    mrController = [[MRController alloc] initWithAdViewFrame:adFrame adPlacementType:MRAdViewPlacementTypeInline];
    mrController.delegate = self;
    [mrController loadAdWithConfiguration:configuration];
    
    
//    MRBridge *bridge = [[MRBridge alloc] initWithWebView:webView];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - MRControllerDelegate

-(NSString *)adUnitId{
    return nil;
}
-(MMAdConfiguration *)adConfiguration{
    return nil;
}
-(CLLocation *)location{
    return nil;
}


-(UIViewController *)viewControllerForPresentingModalView{
    return nil;
}

-(void)appShouldSuspendForAd:(UIView *)adView{
    
}

-(void)appShouldResumeFromAd:(UIView *)adView{
    
}

-(void)adDidLoad:(UIView *)adView{
    
}

-(void)adDidFailToLoad:(UIView *)adView{
    
}

-(void)adWillClose:(UIView *)adView{
    
}

-(void)adDidClose:(UIView *)adView{
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
