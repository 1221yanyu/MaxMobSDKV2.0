//
//  MMAdConfiguration.m
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/7.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import "MMAdConfiguration.h"


NSString * const kAdTypeHeaderKey = @"X-Adtype";
NSString * const kOrientationTypeHeaderKey = @"X-Orientation";
NSString * const kAdUnitWarmingUpHeaderKey = @"X-Warmup";
NSString * const kInterstitialAdTypeHeaderKey = @"X-Fulladtype";

@interface MMAdConfiguration ()

@property (nonatomic, copy) NSString *adResponseHTMLString;

@end


@implementation MMAdConfiguration

-(id)initWithHeaders:(NSDictionary *)headers data:(NSData *)data
{
    self = [self init];
    
    if (self){
        self.adResponseData = data;
        
        self.adType = [self adTypeFromHeaders:headers];
        
        self.adUnitWarmingUp = [[headers objectForKey:kAdUnitWarmingUpHeaderKey] boolValue];
        
        self.networkType = [self networkTypeFromHeaders:headers];
    }
    return self;
}


-(BOOL)hasPreferredSize
{
    return (self.preferredSize.width > 0 && self.preferredSize.height > 0);
}

-(NSString *)adResponseHTMLString
{
    if (!_adResponseHTMLString) {
        self.adResponseHTMLString = [[NSString alloc] initWithData:self.adResponseData encoding:NSUTF8StringEncoding];
    }
    return _adResponseHTMLString;
}

-(NSString *)clickDetectionURLPrefix
{
    return self.interceptURLPrefix.absoluteString ? self.interceptURLPrefix.absoluteString:@"";
}

#pragma mark - provate

-(MMAdType)adTypeFromHeaders:(NSDictionary *)headers
{
    NSString *adTypeString = [headers objectForKey:kAdTypeHeaderKey];
    
    if ([adTypeString isEqualToString:@"interstitial"])
    {
        return MMAdTypeInterstitial;
    }else if (adTypeString && [headers objectForKey:kOrientationTypeHeaderKey])
    {
        return MMAdTypeInterstitial;
    }else if (adTypeString)
    {
        return MMAdTypeBanner;
    }else
    {
        return MMAdTypeUnknown;
    }
    
}

-(NSString *)networkTypeFromHeaders:(NSDictionary *)headers
{
    NSString *adTypeString = [headers objectForKey:kAdTypeHeaderKey];
    if ([adTypeString isEqualToString:@"interstitial"]) {
        return [headers objectForKey:kInterstitialAdTypeHeaderKey];
    } else {
        return adTypeString;
    }
}
@end
