//
//  MRConstants.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

//MRAID广告的一些常量

enum {
    MRAdViewStateHidden,
    MRAdViewStateDefault,
    MRAdViewStateExpanded,
    MRAdViewStateResized
};
typedef NSUInteger MRAdViewState;

enum {
    MRAdViewPlacementTypeInline,
    MRAdViewPlacementTypeInterstitial
};
typedef NSUInteger MRAdViewPlacementType;

extern NSString *const kOrientationPropertyForceOrientationPortraitKey;
extern NSString *const kOrientationPropertyForceOrientationLandscapeKey;
extern NSString *const kOrientationPropertyForceOrientationNoneKey;
