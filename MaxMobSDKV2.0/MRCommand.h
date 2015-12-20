//
//  MRCommand.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/4.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MRCommand;

@protocol MRCommandDelegate <NSObject>

-(void)mrCommand:(MRCommand *)command createCalendarEventWithParams:(NSDictionary *)params;
-(void)mrCommand:(MRCommand *)command playVideoWithURL:(NSURL *)url;
-(void)mrCommand:(MRCommand *)command storePictureWithURL:(NSURL *)url;
-(void)mrCommand:(MRCommand *)command shouldUseCustomClose:(BOOL)useCustomClose;
-(void)mrCommand:(MRCommand *)command setOrientationPropertiesWithForceOrientation:(UIInterfaceOrientationMask)forceOrientation;
-(void)mrCommand:(MRCommand *)command openURL:(NSURL *)url;
-(void)mrCommand:(MRCommand *)command expandWithParams:(NSDictionary *)params;
-(void)mrCommand:(MRCommand *)command resizeWithParams:(NSDictionary *)params;
-(void)mrCommandClose:(MRCommand *)command;

@end

@interface MRCommand : NSObject

@property (nonatomic, weak) id<MRCommandDelegate> delegate;

+(id)commandForString:(NSString *)string;

-(BOOL)requiresUserInteractionForPlacementType:(NSUInteger)placementType;

- (BOOL)executableWhileBlockingRequests;
- (BOOL)executeWithParams:(NSDictionary *)params;

@end

//////////////////////////////

@interface MRCloseCommand : MRCommand

@end

//////////////////////////////

@interface MRExpandCommand : MRCommand

@end

//////////////////////////////

@interface MRResizeCommand : MRCommand

@end

//////////////////////////////

@interface MRUseCustomCloseCommand : MRCommand

@end

//////////////////////////////

@interface MRSetOrientationPropertiesCommand : MRCommand

@end

//////////////////////////////

@interface MROpenCommand : MRCommand

@end

//////////////////////////////

@interface MRCreateCalendarEventCommand : MRCommand

@end

//////////////////////////////

@interface MRPlayVideoCommand : MRCommand

@end

//////////////////////////////

@interface MRStorePictureCommand : MRCommand

@end