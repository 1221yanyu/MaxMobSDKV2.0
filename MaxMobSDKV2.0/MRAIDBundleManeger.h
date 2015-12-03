//
//  MRAIDBundleManeger.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/3.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRAIDBundleManeger : NSObject
+(MRAIDBundleManeger *)sharedManager;
-(NSString *)mraidPath;
@end
