//
//  LocalCache.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/14.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//

#import "LocalCache.h"
#import "MaxMobAdViewManager.h"
#define MAX_ALLOWED_FILE_COUNT 10

@implementation LocalCache
- (NSMutableArray*)pickupPngGif:(NSDirectoryEnumerator*)dirEnum{
    NSString *file;
    int k = 0;
    
    NSMutableArray *_fileList = [[NSMutableArray alloc]initWithCapacity:MAX_ALLOWED_FILE_COUNT];
    
    //取出document目录下的png和gif图片，以后还可以分得更细
    while (file = [dirEnum nextObject]) {
        if ([[file pathExtension] isEqualToString: @"png"] || [[file pathExtension]isEqualToString:@"gif" ]) {
            [_fileList insertObject:file atIndex:k];
            k++;
        }
    }
    
    MaxMobprintfDebugLogs(@"pickupPngGif", [@"filelist after picking up the png and gif files: " stringByAppendingFormat: @"%@ fileList count is: %i", _fileList, [_fileList count]]);
    
    return _fileList;
}

- (NSMutableArray*)pickupTxt:(NSDirectoryEnumerator*)dirEnum{
    NSString *file;
    int l = 0;
    NSMutableArray *_fileList = [[NSMutableArray alloc]initWithCapacity:MAX_ALLOWED_FILE_COUNT];
    
    //取出document目录下的png和gif图片，以后还可以分得更细
    while (file = [dirEnum nextObject]) {
        if ([[file pathExtension] isEqualToString: @"jpg"]) {
            [_fileList insertObject:file atIndex:l];
            l++;
        }
    }
    
    MaxMobprintfDebugLogs(@"pickupTxt", [@"filelist after picking up the txt files: " stringByAppendingFormat: @"%@ fileList count is: %i", _fileList, [_fileList count]]);
    
    return _fileList;
    
}

- (NSMutableArray*)sortFile:(NSMutableArray*)_fileList withFileManage:(NSFileManager*)fileManager{
    //    NSString *tempfile;
    NSString *file1 = nil;
    
    if (0 == [_fileList count]) {
        return nil;
    }
    
    file1 = [_fileList objectAtIndex:0];
    NSDate *date1 = [[fileManager attributesOfItemAtPath:file1 error:nil]fileModificationDate];
    
    //取出文件后，按照升序排列，即前面是时间久的文件，后面是时间新的文件，则删除就从0开始删除。
    for (int i = 0; i < [_fileList count] ; i++) {
        for (int j = 0; j < [_fileList count] - i; j++) {
            NSString *file2 = [_fileList objectAtIndex:j];
            NSDate *date2 = [[fileManager attributesOfItemAtPath:file2 error:nil]fileModificationDate];
            
            NSComparisonResult result = [date1 compare:date2];//和时间久的进行比较，找出时间最久的
            switch (result) {
                case -1://ascending
                    break;
                case 0://same
                    break;
                case 1://descending
                    //                    tempfile = file1;
                    file1 = file2;
                    //                    file2 = tempfile;
                    
                    date1 = [[fileManager attributesOfItemAtPath:file1 error:nil]fileModificationDate];
                    
                    //[fileList2 insertObject:file1 atIndex:i];
                    break;
                default:
                    break;
            }
        }
    }
    
    MaxMobprintfDebugLogs(@"sortFile", [@"filelist after sorting the files: " stringByAppendingFormat: @"%@ fileList count is: %i", _fileList, [_fileList count]]);
    
    return _fileList;
}

- (BOOL)existFileAtDir:(NSString*)fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];//取出数组第一元素
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:documentDir];
    
    MaxMobprintfDebugLogs(@"existFileAtDir", [@":documentPaths " stringByAppendingFormat: @"%@ documentDir is: %@  dirEnum: %@", documentPaths, documentDir, dirEnum]);
    
    fileList = nil;
    filePath = nil;
    
    if ([[fileName pathExtension] isEqualToString:@"jpg"]) {
        fileList = [self pickupTxt:dirEnum];
    }else{
        fileList = [self pickupPngGif:dirEnum];
    }
    
    fileList = [self sortFile:fileList withFileManage:fileManager];
    if (!fileList) {
        return NO;
    }
    
    BOOL isDir = NO;
    for (int i = 0; i < [fileList count]; i++) {
        MaxMobprintfDebugLogs([self class], [@"file name in filelist when search: " stringByAppendingFormat:@"%@  filename of search is : %@", [fileList objectAtIndex:i], fileName]);
        isDir = [fileName isEqualToString:[fileList objectAtIndex:i]];
        if (isDir) {
            //如果找到了文件，则需要更新文件的时间need to add code to update the time of access the file
            filePath = [documentDir stringByAppendingPathComponent:fileName];
            
            MaxMobprintfDebugLogs(@"filePath when updating: %@", filePath);
            return YES;
        }
    }
    return NO;
}

- (BOOL)willDeleteFile{
    
    if ([fileList count] > MAX_ALLOWED_FILE_COUNT) {//最多存50, 占有空间多余80％时，则需要删除文件
        return YES;
    }else{
        return NO;
    }
}

- (void)deleteFile{
    //if need to delete the files
    if ([fileList count] > MAX_ALLOWED_FILE_COUNT) {
        for (int i = 0; i < [fileList count] * 0.3; i++) {
            
            NSString *file = [fileList objectAtIndex:i];
            [fileList removeObjectAtIndex:i];
            MaxMobprintfDebugLogs(@"deleteFile", [@"file in filelist when delete is: " stringByAppendingFormat:@"%@", file ]);
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            NSString *documentDir = [documentPaths objectAtIndex:0];
            NSString *deleteFilePath = [documentDir stringByAppendingPathComponent:file];
            
            MaxMobprintfDebugLogs(@"deleteFile", [@"file pate when delete is: " stringByAppendingFormat:@"%@", deleteFilePath]);
            [fileManager removeItemAtPath:deleteFilePath error:nil];
            
        }
    }
    
    MaxMobprintfDebugLogs(@"deleteFile", [@"filelist after deleting the additional png and gif files: " stringByAppendingFormat: @"%@ fileList count is: %i", fileList, [fileList count]]);
    
}

- (NSData *)getFileContent{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [fileManager contentsAtPath:filePath];
    
    if (!data) {
        return nil;
    } else {
        return data;
    }
}

//-(void)dealloc{
//    [super dealloc];
//}

@end
