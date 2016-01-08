//
//  LocalCache.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/14.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalCache : NSObject //本地缓存
{
    NSString* filePath;
    NSMutableArray* fileList;
}

/*****************************************************
 @method initWithFrame:
 @abstract 初始化方法
 @param frame: 控件初始化位置和大小
 @return 返回控件本身.nil: 初始化失败；非nil: 初始化成功
 *****************************************************/
- (BOOL)existFileAtDir:(NSString*)fileName;

/*****************************************************
 @method initWithFrame:
 @abstract 初始化方法
 @param frame: 控件初始化位置和大小
 @return 返回控件本身.nil: 初始化失败；非nil: 初始化成功
 *****************************************************/
- (NSMutableArray*)pickupPngGif:(NSDirectoryEnumerator*)dirEnum;

/*****************************************************
 @method initWithFrame:
 @abstract 初始化方法
 @param frame: 控件初始化位置和大小
 @return 返回控件本身.nil: 初始化失败；非nil: 初始化成功
 *****************************************************/
- (NSMutableArray*)pickupTxt:(NSDirectoryEnumerator*)dirEnum;

/*****************************************************
 @method initWithFrame:
 @abstract 初始化方法
 @param frame: 控件初始化位置和大小
 @return 返回控件本身.nil: 初始化失败；非nil: 初始化成功
 *****************************************************/
- (NSMutableArray*)sortFile:(NSMutableArray*)_fileList withFileManage:(NSFileManager*)fileManager;

/*****************************************************
 @method initWithFrame:
 @abstract 初始化方法
 @param frame: 控件初始化位置和大小
 @return 返回控件本身.nil: 初始化失败；非nil: 初始化成功
 *****************************************************/
- (BOOL)willDeleteFile;

/*****************************************************
 @method initWithFrame:
 @abstract 初始化方法
 @param frame: 控件初始化位置和大小
 @return 返回控件本身.nil: 初始化失败；非nil: 初始化成功
 *****************************************************/
- (void)deleteFile;

/*****************************************************
 @method initWithFrame:
 @abstract 初始化方法
 @param frame: 控件初始化位置和大小
 @return 返回控件本身.nil: 初始化失败；非nil: 初始化成功
 *****************************************************/
//- (NSString*)getFilePath;

/*****************************************************
 @method initWithFrame:
 @abstract 初始化方法
 @param frame: 控件初始化位置和大小
 @return 返回控件本身.nil: 初始化失败；非nil: 初始化成功
 *****************************************************/
- (NSData*)getFileContent;


@end
