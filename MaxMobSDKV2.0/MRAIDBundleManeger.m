//
//  MRAIDBundleManeger.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/3.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MRAIDBundleManeger.h"

@implementation MRAIDBundleManeger

static MRAIDBundleManeger *sharedManager = nil;

+(MRAIDBundleManeger *)sharedManager
{
    if (!sharedManager) {
        sharedManager = [[MRAIDBundleManeger alloc]init];
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
