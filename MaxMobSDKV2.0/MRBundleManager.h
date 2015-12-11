//
//  MRAIDBundleManeger.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/3.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>

//定位MRAID.js脚本
@interface MRBundleManager : NSObject
+(MRBundleManager *)sharedManager;
-(NSString *)mraidPath;
@end
