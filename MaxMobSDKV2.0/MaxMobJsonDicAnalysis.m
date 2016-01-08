//
//  JsonDicAnalysis.m
//  SDK_Sample
//
//  Created by 耶 好 on 11-12-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MaxMobJsonDicAnalysis.h"

@implementation MaxMobJsonDicAnalysis
+ (NSString*)getAdMaxClick:(NSDictionary*)jsonDic
{
    // 获取广告创意id string
    NSString *maxClick = [jsonDic objectForKey:MAXCLICK];
    return maxClick;
}


+ (NSString*)getAdId:(NSDictionary*)jsonDic
{
    // 获取广告创意id string
    NSString *adId = [NSString stringWithFormat:@"%@",[jsonDic objectForKey:ADID]];
    return adId;
}

+ (NSString*)getAdType:(NSDictionary*)jsonDic
{
    NSString *adType = [NSString stringWithFormat:@"%@",[jsonDic objectForKey:ADTYPE]];
    return adType;
}

+ (NSString*)getLinkType:(NSDictionary*)jsonDic
{
    // 获取推广类型字段
    NSString *linkTypeString = [NSString stringWithFormat:@"%@",[jsonDic objectForKey:LINKTYPE]];
    return linkTypeString;
}

+ (NSString*)getLinkString:(NSDictionary*)jsonDic
{
    // 获取推广链接字段
    NSString *linkString = [jsonDic objectForKey:LINKSTRING];
    return linkString;
}

+ (NSString*)getImageLinkString:(NSDictionary*)jsonDic
{
    // 获取图片广告链接字段
    NSString *imageLinkString = [jsonDic objectForKey:IMAGELINKSTRING];
    
    return imageLinkString;
}

+ (BOOL)imageStringIsGif:(NSString*)stringOfImageLink
{
    // 获取图片链接地址最后3个字符
    NSString *imageType = [stringOfImageLink substringFromIndex:(stringOfImageLink.length - 3)];
    
    // 判断是否是gif
    if (([@"gif" isEqualToString:imageType]) || ([@"GIF" isEqualToString:imageType])) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSString*)getIconLinkString:(NSDictionary*)jsonDic
{
    // 获取icon图片链接
    NSString *iconLinkString = [jsonDic objectForKey:ICONLINKSTRING];
    
    return iconLinkString;
}

+ (NSString*)getBgLinkString:(NSDictionary*)jsonDic
{
    NSString *bgLinkString = [jsonDic objectForKey:BGLINKSTRING];
    
    return bgLinkString;
}

+ (NSString*)getTitleString:(NSDictionary*)jsonDic
{
    NSString *titleString = [jsonDic objectForKey:TITLESTRING];
    
    return titleString;
} 

+ (NSString*)getContentString:(NSDictionary*)jsonDic
{
    NSString *contnetString = [jsonDic objectForKey:CONTENTSTRING];
    
    return contnetString;
} 

+ (NSString *)getClickMacro:(NSDictionary *)jsonDic
{
    return [jsonDic objectForKey:CLICKMACRO];
}

+ (NSString*)getLogoString: (NSDictionary*)jsonDic{
    return [jsonDic objectForKey:MaxMobLOGOSTRING];//都是自动释放的
}

+ (NSString *)getVideoLinkString:(NSDictionary*)jsonDic;
{
    NSString *linkString = [jsonDic objectForKey:VIDEO];
    return linkString;
}
// 对接ssp后新添加方法
+ (NSString*)getMtType:(NSDictionary*)jsonDic
{
    NSString *mtType = [NSString stringWithFormat:@"%@",[jsonDic objectForKey:MT]];
    return mtType;
}

+ (NSString*)getBriefString:(NSDictionary*)jsonDic
{
    NSString *briefString = [jsonDic objectForKey:BRIEFSTRING];
    return briefString;
}

+ (NSString *)getHTMLLinkString:(NSDictionary*)jsonDic
{
    NSString *HTMLString = [jsonDic objectForKey:HTML];
    return HTMLString;
}

+ (NSArray *)getPvURlArray:(NSDictionary*)jsonDic
{
    NSArray *pvURLArray = [jsonDic objectForKey:PVURL];
    return pvURLArray;
}

+ (NSArray *)getClkURLArray:(NSDictionary*)jsonDic{
    NSArray *clkURLArray = [jsonDic objectForKey:CLKURL];
    return clkURLArray;
}

@end
