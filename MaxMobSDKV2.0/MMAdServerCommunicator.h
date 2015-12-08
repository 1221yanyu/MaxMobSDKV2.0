//
//  MMAdServerCommunicator.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/8.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMAdConfiguration.h"

@protocol MMAdServerCommunicatorDelegate;

@interface MMAdServerCommunicator : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<MMAdServerCommunicatorDelegate> delegate;
@property(nonatomic,assign,readonly) BOOL loading;

-(id)initWithDelegate:(id<MMAdServerCommunicatorDelegate>)delegate;

-(void)loadURL:(NSURL *)URL;
-(void)cancel;

@end

@protocol MMAdServerCommunicatorDelegate <NSObject>

@required
- (void)communicatorDidReceiveAdConfiguration:(MMAdConfiguration *)configuration;
- (void)communicatorDidFailWithError:(NSError *)error;

@end