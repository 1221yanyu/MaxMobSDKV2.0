//
//  AdAction.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/13.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaxMobJsonDicAnalysis.h"
#import "MaxMobBase64.h"
#import "MaxMobAdViewManager.h"
//跳转类型
#define MARKET                                   @"2"
#define WEB                                      @"1"

@interface AdAction : NSObject //行为
{
   
    NSMutableString *toShowReportStr;
    
    NSMutableString *requsetString;
    NSMutableString *reportString2;
}
@property (nonatomic, retain) NSString *adToShowJumpLink;

-(BOOL)checkAdToShowLinkType:(NSString *)adToShowLinkType linkStr:(NSString *)linkString json:(NSDictionary*)json entype:(NSStringEncoding)entype;

-(void)clickAdToJumpView;

-(void)clickAdToJumpAppStore;

@end
