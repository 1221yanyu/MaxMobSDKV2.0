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
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:<#(CGRect)#>];
    
    MRController *controller = [[MRController alloc] initWithAdViewFrame:<#(CGRect)#> adPlacementType:<#(MRAdViewPlacementType)#>];
    
    MRBridge *bridge = [[MRBridge alloc] initWithWebView:webView];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
