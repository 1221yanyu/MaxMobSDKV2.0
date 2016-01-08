//
//  MaxMobAdViewManager.h
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/8.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//
//                            _ooOoo_
//                           o8888888o
//                           88" . "88
//                           (| -_- |)
//                            O\ = /O
//                        ____/`---'\____
//                      .   ' \\| |// `.
//                       / \\||| : |||// \
//                     / _||||| -:- |||||- \
//                       | | \\\ - /// | |
//                     | \_| ''\---/'' | |
//                      \ .-\__ `-` ___/-. /
//                   ___`. .' /--.--\ `. . __
//                ."" '< `.___\_<|>_/___.' >'"".
//               | | : `- \`.;`\ _ /`;.`/ - ` : | |
//                 \ \ `-. \_ __\ /__ _/ .-` / /
//         ======`-.____`-.___\_____/___.-`____.-'======
//                            `=---='
//
//         .............................................
//                  佛祖保佑             永无BUG
//          佛曰:
//                  写字楼里写字间，写字间里程序员；
//                  程序人员写程序，又拿程序换酒钱。
//                  酒醒只在网上坐，酒醉还来网下眠；
//                  酒醉酒醒日复日，网上网下年复年。
//                  但愿老死电脑间，不愿鞠躬老板前；
//                  奔驰宝马贵者趣，公交自行程序员。
//                  别人笑我忒疯癫，我笑自己命太贱；
//                  不见满街漂亮妹，哪个归得程序员？
#import <Foundation/Foundation.h>
#import "MaxMobAdSDKView.h"
#import "MaxMobInterstitialAdView.h"
#import "MaxMobNativeAd.h"
#import "MaxMobReachability.h"
#import "MaxMobBase64.h"
#import "MaxMobJsonDicAnalysis.h"
#import "MaxMobJSON.h"
#import "UserInfo.h"
#import "ErrorCode.h"
#import "AdType.h"
#import "Advertisement.h"
#import "Transition.h"
#import "UserInfo.h"
#import "TOWebViewController.h"

#define MaxMobiOSSDKVersion @"MaxMob_SDK_iOS_1.2.0"
#define DATABASE @"maxmob"
//#define HEADERDOMAIN @"http://192.168.8.91/m?"
//#define HEADERDOMAIN @"http://192.168.8.164/m?"
//#define HEADERDOMAIN @"http://103.20.251.134/m?"      //ande外网
//#define HEADERDOMAIN @"http://192.168.10.228:81/api/imp?"     //秒硕ssp测试
//#define HEADERDOMAIN @"http://ssp.maxmob.cn/api/imp"    //秒硕ssp
#define HEADERDOMAIN @"http://192.168.80.232:9999/api/imp?"//本地测试

#define TIMEINTERVAL 10

//返回信息
#define SuccessShowAd @"success show banner ad"
#define InterstitialAdIsPrepareOk @"interstitial ad is prepare ok"
#define SuccessShowInterstitialAd @"success show interstitial ad"
#define SuccessShowSplashAd @"success show splash ad"


#define ErrorOfWrongID @"error of wrong id"
#define ErrorOfWrongViewSize @"error of wrong view size"
#define ErrorOfNilController @"errpr of nil controller"
#define ErrorOfEmptyAd @"error of empty ad"
#define ErrorOfNetwork @"error of network"
#define ErrorOfUnknown @"error of unknow"


static const BOOL LogTagError   = YES;
static const BOOL LogTagDebug   = YES;
static const BOOL LogTagTest    = YES ;

static NSString *const MaxMobSDKViewWillEnterBackground  = @"MaxMobSDKViewWillEnterBackground";
static NSString *const MaxMobSDKViewWillEnterForeground  = @"MaxMobSDKViewWillEnterForeground";


@interface MaxMobAdViewManager : NSObject<ToWebViewDelegate>
{
    UIButton *button;
    UIButton *closeBtn;
    BOOL isPrepareAdOK;
    BOOL isHiddenBar;
    NSString *adType;
    NSString *mediaType;
    
    bool DeviceInfoCollected;   //判断是否收集过用户信息；
    bool networkStatus;         //判断网络是否连接；
    
    NSMutableString *requestString; //请求数据字符串
    NSStringEncoding enType ;
    NSTimer *getNetWorkTimer;
    NSTimer *timerOfShowAd;
    NSInteger day;
    
    NSMutableString *reportString; // 上报数据字符串
    NSString *reportAd;
    
    UIView *adShowing;
//    NSString *adToShowJumpLink;
    NSString *adShowingJumpLink;
    NSString *adShowingLinkType;
    NSMutableString *adShowing_date_id;
    NSMutableString *date_id;
    NSMutableString *toShowReportStr;
    NSMutableString *showingReportStr;

    
    //点击控制
    NSString *pathOfDeClick;
    NSString *pathOfRealClick;
    NSMutableDictionary *clickCtlDic;
    NSMutableDictionary *clickCtlRepDic;
    
    //跳转页面
    TOWebViewController *webViewController;
    
    //上报串
    NSArray *pvURL;
    NSArray *clkURL;
    
    //请求字符串
    NSString* _app_id;         //应用ID
    NSString* _publish_id;     //开发者ID
    NSString* _dist_id;        //渠道ID
    NSString* _user_id;        //终端唯一标识符（idfa）
    NSString* _imsi;
    NSString* _imei;           //imei串号
    NSString* _mobile;         //手机号码
    NSString* _cell_id;        //基站表识
    NSString* _gps;            //GPS坐标
    NSString* _screenSize;     //屏幕大小
    NSString* _os;             //操作系统
    NSString* _osv;            //操作系统版本号
    NSString* _platform;       //平台
    NSString* _chip;
    NSString* _model;          //手机型号
    NSString* _brand;          //手机品牌
    NSString* _operators;      //运营商
    NSString* _adSpace;        //广告位标识符
    NSString* _channelSize;    //广告位尺寸
    NSString* _adWeight;       //广告宽度
    NSString* _adHeight;       //广告高度
    NSString* _ct;
    NSString* _type;           //广告位类型
    NSString* _mt;             //媒体类型
    NSString* _borderColor;
    NSString* _bgColor;
    NSString* _txtColor;
    NSString* _lang;           //系统语言
    NSString* _output;         //广告输出格式
    NSString* _encrypt;        //是否加密
    NSString* _testMode;       //是否测试模式
    NSString* _database;       //数据库
    NSString* _access;         //联网方式  0为无网络，2为wwan,1为WiFi
    NSString* _bid;        //SDK版本号
    NSString* _adType;
   
    NSString* _test;
    NSString* _fmt;
    NSString* _cs;
}
@property(nonatomic)bool isiPad;
@property(nonatomic)bool instlAdIsPrepare;
@property(nonatomic)bool isRTSplash;
@property (nonatomic, assign) NSString * RTSplashAdID;
@property (nonatomic, assign) NSString *networkStatusStr;
@property (nonatomic, assign) NSString *adToShowJumpLink;
@property (nonatomic, assign) UIView *adToShow;
@property (nonatomic, assign) NSString *adToShowLinkType;
@property (nonatomic, retain) NSString *documentDir;   //文件目录
@property (nonatomic, assign) NSString *jumpLinkURL;//点击数超限时，就直接跳转到网页，不再用重定向
@property (nonatomic, assign) NSString *adid;


//开发者传进来的值
@property (nonatomic, assign)id<MaxMobAdSDKViewDelegate,MaxMobInterstitialAdControllerDelegate> delegate;
@property (nonatomic, assign)id<MaxMobNativeDelegate> nativeDelegate;
@property (nonatomic, assign)UIViewController *controller;
@property (nonatomic, assign)NSString* userKey;
@property (nonatomic, assign)MaxMobAdSDKView* maxmobAdSDKView;
@property (nonatomic, assign)MaxMobInterstitialAdView* maxmobInterstitialAdView;
@property (nonatomic) BOOL isCache;
@property (nonatomic,assign) NSString *orientationStatus;
@property (nonatomic, assign)UIViewController *nativeViewController;
@property (nonatomic, assign)NSString* adStyle;





@property(nonatomic, assign) NSString* _headerDomain;   //接头URL


-(id)init;
-(void)prepareRequset;
-(void)prepareNativeRequset;
-(void)prepareNativeRequsetWithStyle:(NSString *)style;
-(void)nativeAdClick;
+(id)sendURL:(NSString *)urlString;
//- (void)reportToDE:reportString;
-(void)clickShowInstlAd;
-(void)showInstlAd;
-(void)showRTSplashAd;
//-(void)showSplash;
-(void)stop;

void MaxMobcatchErrors(id object, id errorDescription);

void MaxMobprintfDebugLogs(id object, id logDescription);

void MaxMobprintfTestLogs(id object, id logDescription);
@end

