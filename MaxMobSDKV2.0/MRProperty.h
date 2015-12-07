//
//  MRProperty.h
//  MaxMobSDKV2.0
//
//  Created by Jacob on 15/12/7.
//  Copyright © 2015年 Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRConstants.h"
#import <UIKit/UIKit.h>

//MRAID广告的一些属性
@interface MRProperty : NSObject

-(NSString *)description;
-(NSString *)jsonString;

@end

/////////////////////////////////////

@interface MRHostSDKVersionProPerty : MRProperty

@property (nonatomic, copy)NSString *version;
+(MRHostSDKVersionProPerty *)defaultProperty;

@end

/////////////////////////////////////

@interface MRPlacementTypeProperty : MRProperty {
    MRAdViewPlacementType _placementType;
}

@property (nonatomic, assign) MRAdViewPlacementType placementType;

+ (MRPlacementTypeProperty *)propertyWithType:(MRAdViewPlacementType)type;

@end

/////////////////////////////////////

@interface MRStateProperty : MRProperty {
    MRAdViewState _state;
}

@property (nonatomic, assign) MRAdViewState state;

+(MRStateProperty *)propertyWityState:(MRAdViewState)state;

@end

/////////////////////////////////////

@interface MRScreenSizeProperty : MRProperty {
    CGSize _screenSize;
}

@property (nonatomic, assign) CGSize screenSize;

+(MRScreenSizeProperty *)propertyWithSize:(CGSize)size;

@end

/////////////////////////////////////

@interface MrSupportProperty : MRProperty

@property (nonatomic, assign) BOOL supportsSms;
@property (nonatomic, assign) BOOL supportsTel;
@property (nonatomic, assign) BOOL supportsCalendar;
@property (nonatomic, assign) BOOL supportsStorePicture;
@property (nonatomic, assign) BOOL supportsInlineVideo;

+(NSDictionary *)supportedFeatures;
+(MrSupportProperty *)defaultProperty;
+(MrSupportProperty *)propertyWithSupportedFeaturesDictionary:(NSDictionary *)dictionary;

@end

/////////////////////////////////////

@interface MRViewableProperty : MRProperty {
    BOOL _isViewable;
}

@property (nonatomic, assign) BOOL isViewable;

+(MRViewableProperty *)porpertyWithViewable:(BOOL)viewable;

@end