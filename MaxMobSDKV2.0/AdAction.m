//
//  AdAction.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/13.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "AdAction.h"

@implementation AdAction
{
   
}
@synthesize adToShowJumpLink;
-(id)init
{
    self = [super init];
    
    return self;
}

-(BOOL)checkAdToShowLinkType:(NSString *)adToShowLinkType linkStr:(NSString *)linkString json:(NSDictionary*)json entype:(NSStringEncoding)entype
{
//    NSString *decodeStr = maxmobURLDecode(linkString);
        if ([WEB isEqualToString:adToShowLinkType]) {
//        NSString *link = [self creatReportLinkString:json adToShowLinkType:adToShowLinkType entype:entype];
//            NSString *link = [MaxMobJsonDicAnalysis getLinkString:json];
        if (adToShowJumpLink) {
//            [adToShowJumpLink release];
        }
//        adToShowJumpLink = [[NSMutableString alloc] initWithString:link];
        adToShowJumpLink = [MaxMobJsonDicAnalysis getLinkString:json];
        MaxMobprintfDebugLogs(@"img: the report string of jumping to web: %@", adToShowJumpLink);
        return YES;
    }else if([MARKET isEqualToString:adToShowLinkType]){
//        NSString *link = [self setJumpLinkOfMarket:decodeStr];
        if (adToShowJumpLink) {
//            [adToShowJumpLink release];
        }
        adToShowJumpLink = [[NSMutableString alloc] initWithString:[MaxMobJsonDicAnalysis getLinkString:json]];
        if (toShowReportStr) {
//            [toShowReportStr release];
        }
        toShowReportStr = [[NSMutableString alloc] initWithString:[self creatReportLinkString:json adToShowLinkType:adToShowLinkType entype:entype]];
         MaxMobprintfDebugLogs(@"prepareJumpLink: the report string of jumping to app store: %@", toShowReportStr);
        return YES;
    }else
    {
        return NO;
    }
}

/*
 *上报链接生成
 *输出，重定向所用的链接string
 *!!输出为alloc,使用后需要释放
 *参数1,jsonDic
 */
- (NSString*)creatReportLinkString:(NSDictionary*)jsonDic adToShowLinkType:(NSString *)adToShowLinkType entype:(NSStringEncoding)enType
{
    NSString *acS = [jsonDic objectForKey:CLICKMACRO];
    NSArray *acArray = [acS componentsSeparatedByString:SEPERATOR]; //返回从原串中去掉参数字符串的子串
    
    NSString *acString0 = [NSString stringWithString:[acArray objectAtIndex:0]];
    NSString *acString1 = [NSString stringWithString:[acArray objectAtIndex:1]];
    
    NSMutableString *linkString1 = [[NSMutableString alloc]initWithString:@"&u="] ; //存储u 字符串的
    NSString *linkString2 = [NSString stringWithString:[jsonDic objectForKey:LINKSTRING]];
    
    if ([MARKET isEqualToString:adToShowLinkType]) {
        linkString2 = [self setJumpLinkOfMarket:linkString2];
    }else if([WEB isEqualToString:adToShowLinkType]){
        NSString *jumpLinkURL = [MaxMobAdViewManager alloc].jumpLinkURL;
        if (jumpLinkURL) {
//            [jumpLinkURL release];
            jumpLinkURL = nil;
        }
        jumpLinkURL = [[NSString alloc] initWithString:maxmobURLDecode(linkString2)];
    }
    
    [linkString1 appendString:linkString2];
    
    NSString *deliverStr = [[NSString alloc] initWithString:acString1];
    deliverStr = [deliverStr stringByAppendingFormat:@"&%@", reportString2];
//    [reportString2 release];
    reportString2 = nil;
    //add nf field
    if ([WEB isEqualToString:adToShowLinkType]) {
        deliverStr = [deliverStr stringByAppendingString:@"&nf=0"];
    }else if([MARKET isEqualToString:adToShowLinkType]){
        deliverStr = [deliverStr stringByAppendingString:@"&nf=1"];
    }
    deliverStr = [deliverStr stringByAppendingString:linkString1];
//    [linkString1 release];
    NSString *encodedString = [MaxMobBase64 encode:[deliverStr dataUsingEncoding:enType]];
    acString0 = [acString0 stringByAppendingString:SEPERATOR];
    acString0 = [acString0 stringByAppendingString:encodedString];
    
    return acString0;
}

- (id)setJumpLinkOfMarket:(NSString *)jumpLinkStr{
    NSString *stringLinkBody = [jumpLinkStr substringFromIndex:7];
    
    NSString *stringItem = @"itms-apps://ax.";
    NSString *stringAPPLink = [stringItem stringByAppendingString:stringLinkBody];
    
    return  stringAPPLink;
}
NSString * maxmobURLDecode(NSString *__autoreleasing encodedURLString){
    NSString *decodeResult = [encodedURLString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    decodeResult = [decodeResult stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return decodeResult;
}
@end
