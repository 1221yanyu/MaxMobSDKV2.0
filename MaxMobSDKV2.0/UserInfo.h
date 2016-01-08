//
//  UesrInfo.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/14.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreLocation/CoreLocation.h>
#import "MaxMobAdViewManager.h"
#import "MaxMobAdSDKView.h"
#import "CCLocationManager.h"
#import <AdSupport/AdSupport.h>
@interface UserInfo : NSObject <CLLocationManagerDelegate> //获取用户设备信息
{
    
}
@property(nonatomic, assign)MaxMobAdSDKView *_mmAdSDKView;
NSString * URLEncode(NSString *originalString);
NSString * URLDecode(NSString *encodedURLString);

//设备不变信息
+ (NSString*)getIDFA;
+ (NSString*)getScreenResolutionSize;   //
+ (NSString*)getOS;                     //
+ (NSString*)getOSV;                     //
+ (NSString*)getPlatform;               //
+ (NSString*)getBrand;                  //
+ (NSString*)getCellID;                 //
+ (NSString*)getBundleID;               //
+ (void)startUpdatingGPS;
/**
 * must be called after calling + (void)startUpdatingGPS;
 */
+ (NSString*)getGPS;                    //
+ (NSString*)getIMEI;                   //
+ (NSString*)getLang;                   //
+ (NSString*)getMobile;                 //
+ (NSString*)getModel;                  //
+ (NSString*)getOperators;              //
//+ (NSString*)getUserID;

//和广告相关的信息
+ (NSString*)getDistID;                 //
+ (NSString*)getChannelSize:(NSString*)spaceType;//
+ (NSString*)getOutput;                 //
+ (NSString*)getEncrypt;                //
+ (NSString*)getTestMode;               //
+ (NSString*)getVersion;                //
//不收集
+ (NSString*)getChip;
+ (NSString*)getIMSI;
+ (NSString*)getBorderColor;
+ (NSString*)getBgColor;
+ (NSString*)getTxtColor;
+ (NSString*)getCt;

@end
