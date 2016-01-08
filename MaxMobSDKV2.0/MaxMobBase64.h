//
//  MaxMobBase64.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/13.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaxMobBase64 : NSObject
+ (void) initialize;

+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;

+ (NSString*) encode:(NSData*) rawBytes;

+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;

+ (NSData*) decode:(NSString*) string;


@end
