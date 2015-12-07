//
//  MRAIDBundleManeger.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/3.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MRBundleManeger.h"

@implementation MRBundleManeger

static MRBundleManeger *sharedManager = nil;

+(MRBundleManeger *)sharedManager
{
    if (!sharedManager) {
        sharedManager = [[MRBundleManeger alloc]init];
    }
    return sharedManager;
}

-(NSString *)mraidPath
{
    NSBundle *parentBundle = [NSBundle mainBundle];
    NSString *mraidBundlePath = [parentBundle pathForResource:@"MRAID" ofType:@"bundle"];
    NSBundle *mraidBundle = [NSBundle bundleWithPath:mraidBundlePath];
    return [mraidBundle pathForResource:@"mraid" ofType:@"js"];
}

@end
