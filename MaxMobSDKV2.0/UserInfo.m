//
//  UesrInfo.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/14.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "UserInfo.h"
#import <sys/utsname.h>

#define LOCATIION_MANAGER_DISTANCE_FILTER   700.0f// GPS定位刷新的最小距离间隔
static NSString *currentGPS = nil;
static CLLocationManager *locationManager = nil;
@implementation UserInfo
NSString * URLEncode(NSString *originalString){
    //!  @  $  &  (  )  =  +  ~  `  ;  '  :  ,  /  ?
    //%21%40%24%26%28%29%3D%2B%7E%60%3B%27%3A%2C%2F%3F
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
                            @"@" , @"&" , @"=" , @"+" , @"$" , @"," ,
                            @"!", @"'", @"(", @")", @"*", nil];
    
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F", @"%3F" , @"%3A" ,
                             @"%40" , @"%26" , @"%3D" , @"%2B" , @"%24" , @"%2C" ,
                             @"%21", @"%27", @"%28", @"%29", @"%2A", nil];
    
    int len = [escapeChars count];
    
    NSMutableString *temp = [[originalString
                              stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                             mutableCopy];
    
    int i;
    for (i = 0; i < len; i++) {
        
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    NSString *outStr = [NSString stringWithString: temp];
//    [temp release];
    temp = nil;
    NSString *encodeResult = [outStr stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
    
    return encodeResult;
    
}

NSString * URLDecode(NSString *__autoreleasing encodedURLString){
    NSString *decodeResult = [encodedURLString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    decodeResult = [decodeResult stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return decodeResult;
}

+ (NSString*)getIDFA
{
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return adId;
}

+ (NSString*)getScreenResolutionSize
{
    CGRect screenResolution = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [UIScreen mainScreen].scale;
    int scale = screenScale*1;
    int height = screenResolution.size.height*scale;
    int width = screenResolution.size.width*scale;
    NSString *screenResolutionSize = [NSString stringWithFormat:@"%i|%i", height, width];
    
    return screenResolutionSize;
}

+ (NSString*)getOS{
    NSString *systemName = [[UIDevice currentDevice]systemName];
//    NSString *os = [NSString stringWithFormat:@"%@", systemName];
//    NSString *osStr = URLEncode(systemName);
    return systemName;
}

+ (NSString*)getOSV{
    NSString *systemVersion = [[UIDevice currentDevice]systemVersion];
    NSString *osv = [NSString stringWithFormat:@"%@",systemVersion];
    NSString *osvStr = URLEncode(osv);
    return osvStr;
}
+ (NSString*)getPlatform{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return @"3";
    }else
    {
        return @"4";
    }
//    return @"iOS";
//    struct utsname systemInfo;
//    uname(&systemInfo);
//    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
//    return platform;
//    
//    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
//    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
//    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
//    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
//    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
//    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
//    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
//    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
//    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
//    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
//    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
//    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])         return @"iPhone Simulator";
//    return platform;
}

+ (NSString*)getBrand{
    NSString *urlencodeBrand = URLEncode(@"Apple");
    return urlencodeBrand;
}
+ (NSString*)getCellID{
    return @"";
}

+ (NSString*)getBundleID{
    NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];//获取info－plist
    NSString *bundleID  =  [dic objectForKey:@"CFBundleIdentifier"];//获取Bundle identifier
    return bundleID;
}
/**
 * shared locationManager
 */
+ (CLLocationManager *)sharedlocationManager
{
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
            [locationManager requestAlwaysAuthorization];        //NSLocationAlwaysUsageDescription
            [locationManager requestWhenInUseAuthorization];     //NSLocationWhenInUseDescription
        }
        
        locationManager.delegate = (id<CLLocationManagerDelegate>)[UserInfo class];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = LOCATIION_MANAGER_DISTANCE_FILTER;
    }
    
    return locationManager;
}
#pragma mark -
#pragma mark - CLLocationManage Delegate Methods
// delegate for corelocation
+ (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (currentGPS) {
//        [currentGPS release];
    }
    currentGPS = [[NSString alloc] initWithFormat:@"%.5lf|%.5lf", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    [locationManager stopUpdatingLocation];
}
+ (void)startUpdatingGPS
{
    // call shared locationManager to start updating location
    [UserInfo sharedlocationManager];
    
//    [locationManager startUpdatingLocation];
    
//    if([[UserInfo sharedlocationManager] respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [[UserInfo sharedlocationManager] requestAlwaysAuthorization]; // 永久授权
//        [[UserInfo sharedlocationManager] requestWhenInUseAuthorization]; //使用中授权
//    }
    [[UserInfo sharedlocationManager] startUpdatingLocation];
}
+ (NSString*)getGPS
{
    
    if (!currentGPS) {
        return @"";
    }
    
    return currentGPS;
}
+ (NSString*)getIMEI{
    return @"";
}
+ (NSString*)getLang{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString *currentLanguage = [languages objectAtIndex:0];
    return currentLanguage;
}
+ (NSString*)getMobile{
    return @"";
}
+ (NSString*)getModel{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //return platform;
    
    NSString *modelStr = [[UIDevice currentDevice]model];
    MaxMobprintfDebugLogs(@"modelstr", modelStr);
    
    NSRange range = [modelStr rangeOfString:@"Simulator"];
    NSRange rangeOfModel1 = [modelStr rangeOfString:@"x86_64"];
    
    if ([platform isEqualToString:@"Simulator"] ||
        [platform isEqualToString:@"x86_64"]) {
        return @"Simulator";
    }else{
        //        NSString *urlencodeModel = URLEncode(platform);
        return platform;
    }
//    if (range.length != 0 ||
//        rangeOfModel1.length != 0) {
//        return @"Simulator";
//    }else{
////        NSString *urlencodeModel = URLEncode(platform);
//        return platform;
//    }
}

+ (NSString*)getOperators{
    int version = [[[UIDevice currentDevice]systemVersion] intValue];
    if (version < 4) {
        return @"0";
    }
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrierName = networkInfo.subscriberCellularProvider;
    NSString *mobileCountryCode = carrierName.mobileCountryCode;
    NSString *mobileNetworkCode = carrierName.mobileNetworkCode;
//    NSString *operators = [mobileCountryCode stringByAppendingString:mobileNetworkCode] ;
    NSString *operators;
    if ([mobileNetworkCode isEqualToString:@"02"]) {
        operators = @"1";
    }else if ([mobileNetworkCode isEqualToString:@"01"])
    {
        operators = @"2";
    }else if ([mobileNetworkCode isEqualToString:@"03"])
    {
        operators = @"3";
    }else
    {
        return @"0";
    }
//    [networkInfo release];
    networkInfo = nil;
    if (!mobileNetworkCode) {
        return @"0";
    }
    return operators;
    
}
/*
+ (NSString *)getUserID{
    NSString *userID = [MaxMobOpenUDID value];
    if (!userID) {
        return @"";
    }else {
        return userID;
    }
}
*/

+ (NSString*)getDistID{
    return @"";
}

+ (NSString *)getChannelSize:(NSString*)spaceType{
    int intSpaceType = [spaceType intValue];
    NSString *_channelSize;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    int scale = screenScale*1;
//    switch (intSpaceType) {
//        case MaxMobTypeOfAdSpace_Banner://banner
//            if (isiPad) {
//                _channelSize = @"100|768";
//            }else{//iPhone
//                switch (scale) {
//                    case 1:
//                        _channelSize = @"50|320";
//                        break;
//                    case 2:
//                        _channelSize = @"100|640";
//                        break;
//                    default:
//                        _channelSize = @"100|640";
//                        break;
//                }
//            }
//            break;
//        case MaxMobTypeOfAdSpace_Full_Img://full img
//        case MaxMobTypeOfAdSpace_Full_Video://full video
//            if (isiPad) {
//                _channelSize = [@"" stringByAppendingString: @"1024|768"];
//            }else{//iPhone
//                _channelSize = [@"" stringByAppendingString: @"940|640"];
//            }
//            break;
//            
//        default://other
//            MaxMobcatchErrors(@"Set DEVID", @"应用ID不合法！");
//            _channelSize = @"";
//            break;
//    }
    return _channelSize;
}

+ (NSString *)getOutput{
    return @"6";
}
+ (NSString *)getEncrypt{
    return @"1";
}

+ (NSString *)getTestMode{
    return @"";
}
+(NSString *)getVersion
{
    return MaxMobiOSSDKVersion;
}

//不收集
+ (NSString*)getChip{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *version = [NSString stringWithCString:systemInfo.version encoding:NSUTF8StringEncoding];
    
    NSArray *array = [version componentsSeparatedByString:@"/"];
    NSString *chip = nil;
    if ([array count] > 1) {
        chip = [NSString stringWithString:[array objectAtIndex:1]];
    }else {
        chip = @"";
    }
    
    return chip;
}
+ (NSString*)getIMSI{
    return @"";
}
+ (NSString *)getBorderColor{
    return @"";
}

+ (NSString *)getBgColor{
    return @"";
}

+ (NSString *)getTxtColor{
    return @"";
}
+ (NSString *)getCt{
    return @"";
    NSString *modelStr = [[UIDevice currentDevice] model];
    NSRange rangeOfModel = [modelStr rangeOfString:@"Simulator"];
    NSRange rangeOfModel1 = [modelStr rangeOfString:@"x86_64"];
    
    if (rangeOfModel.length != 0 ||
        rangeOfModel1.length != 0) {
        return @"1";
    }
    return @"0";
}

@end
