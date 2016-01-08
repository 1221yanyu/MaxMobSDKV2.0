//
//  JsonDicAnalysis.h
//  SDK_Sample
//
//  Created by 耶 好 on 11-12-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ADID            @"ad"       //广告id
#define ADTYPE          @"type"     //广告位类型
#define MT              @"mt"       //广告创意类型
#define LINKSTRING      @"url"      //点击跳转URL
#define IMAGELINKSTRING @"purl"     //图片创意URL
#define VIDEO           @"vi"       //视频创意URL
#define HTML            @"html"     //HTML创意
#define ICONLINKSTRING  @"icon"     //icon URL
#define BGLINKSTRING    @"bg"       //
#define TITLESTRING     @"title"    //广告标题
#define BRIEFSTRING     @"desc"     //广告简介
#define CONTENTSTRING   @"txt"      //广告正文
#define LINKTYPE        @"acttype"  //推广方式
#define PVURL           @"pvurl"    //展示监测URL
#define CLKURL          @"clkurl"   //点击监测URL
#define CLICKMACRO      @"ac"
#define MAXCLICK        @"mac"
#define SEPERATOR       @"?"
#define MaxMobLOGOSTRING  @"og"


@interface MaxMobJsonDicAnalysis : NSObject

//获取最大的点击数
+ (NSString*)getAdMaxClick:(NSDictionary*)jsonDic;

/*
 *返回值，广告创意id string
 *参数1,jsonDic
 */



+ (NSString*)getAdId:(NSDictionary*)jsonDic;

/*
 *返回值，广告类型string img / txt
 *参数1，jsonDic
 */



+ (NSString*)getAdType:(NSDictionary*)jsonDic;

/*
 *返回值，广告推广类型，APP WEBPAGE 或者－1
 *参数1,jsonDic
 */

//获取广告创意类型
+ (NSString*)getMtType:(NSDictionary*)jsonDic;


+ (NSString*)getLinkType:(NSDictionary*)jsonDic;

/*
 *返回值，推广链接直接地址，app直接使用，但需要上报；web需要重定向加工
 *参数1,jsonDic
 */
+ (NSString*)getLinkString:(NSDictionary*)jsonDic;

/*
 *返回值，图片广告链接string
 *参数1,jsonDic
 */
+ (NSString*)getImageLinkString:(NSDictionary*)jsonDic;

/*
 *判断图片链接是否指向gif格式图片
 *返回值，YES，gif图片；NO，非gif图片
 */
+ (BOOL)imageStringIsGif:(NSString*)stringOfImageLink;

/*
 *返回值，文本广告icon的链接string
 *参数1,jsonDic
 */
+ (NSString*)getIconLinkString:(NSDictionary*)jsonDic;

/*
 *返回值，文本广告bgImage的链接string
 *参数1,jsonDic
 */
+ (NSString*)getBgLinkString:(NSDictionary*)jsonDic;

/*
 *返回值，文本广告的标题string
 *参数1，jsonDic
 */
+ (NSString*)getTitleString:(NSDictionary*)jsonDic;
/*
 *返回值，文本广告简介string
 *参数1，jsonDic
 */
+ (NSString*)getBriefString:(NSDictionary*)jsonDic;
/*
 *返回值，文本广告的内容string
 *参数1，jsonDic
 */
+ (NSString*)getContentString:(NSDictionary*)jsonDic;

//获取点击宏
+ (NSString*)getClickMacro: (NSDictionary*)jsonDic;

//获取logo标签，判断是否需要显示logo
+ (NSString*)getLogoString: (NSDictionary*)jsonDic;

/**
 * 获取视频资源请求地址
 */
+ (NSString *)getVideoLinkString:(NSDictionary*)jsonDic;

//获取HTML地址
+ (NSString *)getHTMLLinkString:(NSDictionary*)jsonDic;
//获取展示上报URL数组
+ (NSArray *)getPvURlArray:(NSDictionary*)jsonDic;
//获取点击上报URL数组
+ (NSArray *)getClkURLArray:(NSDictionary*)jsonDic;
@end
