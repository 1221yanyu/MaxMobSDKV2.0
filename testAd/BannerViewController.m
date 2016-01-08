//
//  ViewController.m
//  testAd
//
//  Created by Jacob on 15/12/10.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "BannerViewController.h"
//#import "MRControllerNew.h"

@interface BannerViewController ()

@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *PublishID = @"M3xudWxsfDB8MA==";
    NSString *PlacementID = @"MTB8M3wyM3wx";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        maxmobAdView = [[MaxMobAdSDKView alloc] initAd:PublishID placement:PlacementID position: CGRectMake(0, 100, 320, 50 ) delegate:self];
    } else {
        maxmobAdView = [[MaxMobAdSDKView alloc] initAd:PublishID placement:PlacementID position: CGRectMake(0, 100, 768, 100) delegate:self];
    }
    [maxmobAdView loadAd:self];//adview instance begin to request ad.
    [self.view addSubview:maxmobAdView];//add the adview to the current view to show it.
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didAdReceived:(id)view withStatus:(NSString*)resultStatus{//when finished requesting a ad, then callback this method, return status.
    NSLog(@"result status is: %@", resultStatus);
}

- (void)onClicked:(id)view toWhere:(NSString *)toWhere{//when user clicked the view, then callback this method, 'toWhere' means the
    NSLog(@"toWhere is: %@", toWhere);
}

- (void)willDismissScreen:(id)view{//when user clicked the done button from webview, then callback this method.
    NSLog(@"Come back to ad view.");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
