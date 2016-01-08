  //
//  MaxMobAdViewManager.m
//  MaxMobSDKV1
//
//  Created by Jacob on 15/4/8.
//  Copyright (c) 2015年 Jacob. All rights reserved.
//
//
// _oo0oo_
//088888880
//88" . "88
//(| -_- |)
// 0\ = /0
// _/'---'\___
//.' \\|     |// '.
/// \\|||  :  |||// \
///_ ||||| -:- |||||- \
//|   | \\\  -  /// |   |
//| \_|  ''\---/''  |_/ |
//\  .-\__  '-'  __/-.  /
//___'. .'  /--.--\  '. .'___
//."" '<  '.___\_<|>_/___.' >'  "".
//| | : '-  \'.;'\ _ /';.'/ - ' : | |
//\  \ '_.   \_ __\ /__ _/   .-' /  /
//'-.____'.___ \_____/___.-'____.-'
//
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//佛祖也累了。。。。


#import "MaxMobAdViewManager.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
@interface MaxMobAdViewManager ()
{
    Advertisement *ad;
}

@end

@implementation MaxMobAdViewManager

@synthesize delegate = _mmAdViewDelegate;
@synthesize nativeDelegate = _nativeDelegate;
@synthesize controller = _mmAdViewController;
@synthesize maxmobAdSDKView = _maxmobAdSDKView;
@synthesize maxmobInterstitialAdView = _maxmobInterstitialAdView;
@synthesize isCache; 
@synthesize orientationStatus = _orientationStatus;

@synthesize isiPad;
@synthesize userKey;
@synthesize _headerDomain;
//@synthesize _app_id, _publish_id, _dist_id, _user_id, _imsi, _imei, _mobile, _cell_id, _gps, _screenSize, _os,_osv, _platform, _chip, _model, _brand, _operators, _adSpace, _channelSize, _adWeight, _adHeight,_ct, _type, _mt, _borderColor, _bgColor, _txtColor, _lang, _output, _encrypt, _testMode, _database, _access, _bid, _test, _fmt,_cs;
//@synthesize _adType;

@synthesize networkStatusStr = _networkStatusStr;
@synthesize adToShow = _adToShow;
@synthesize adToShowLinkType = _adToShowLinkType;
@synthesize adToShowJumpLink = _adToShowJumpLink;
@synthesize documentDir = _documentDir;
@synthesize jumpLinkURL = _jumpLinkURL;
@synthesize adid;
@synthesize adStyle = _adStyle;

-(id)init
{
    self = [super init];
    if (self) {
//        [self initInstanceVariales];
        self.instlAdIsPrepare = NO;
        DeviceInfoCollected = NO;
        networkStatus = NO;
        _networkStatusStr = @"no";
        enType = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSDate * startDate = [[NSDate alloc] init];
            ad = [[Advertisement alloc]init];
        NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
        NSUInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute |
        NSCalendarUnitSecond | NSCalendarUnitDay  |
        NSCalendarUnitMonth | NSCalendarUnitYear;
        
        NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:startDate];
        day = [cps day];
        
//        [startDate release];
        
        
        
        
//        [chineseCalendar release];
        if (self) {
            NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
            _documentDir = [[NSString alloc] initWithString:[documentPaths objectAtIndex:0]];
        }
        
        
        
//        [UserInfo startUpdatingGPS];
        
        /* 注册监听sdk进入后台事件 */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdkViewWillEnterBackground) name:MaxMobSDKViewWillEnterBackground object:nil];
        
        /* 注册监听sdk后台唤醒事件 */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdkViewWillEnterForeground) name:MaxMobSDKViewWillEnterForeground object:nil];
        
           }
    return self;
}
//- (void)initInstanceVariales
//{
//    getNetWorkTimer = nil;
//    timerOfShowAd = nil;
//    _adToShowJumpLink = nil;
//    adShowingJumpLink = nil;
//    pathOfDeClick = nil;
//    pathOfRealClick = nil;
//    clickCtlDic = nil;
//    clickCtlRepDic = nil;
//    adType = nil;
//    _jumpLinkURL = nil;
//    _pvURL = nil;
//    _clkURL = nil;
//    
//}

//-(void)dealloc
//{
//    self.userKey = nil;
//    self._app_id = nil;
//    self._publish_id = nil;
//    self._dist_id = nil;
//    self._user_id = nil;
//    self._imsi = nil;
//    self._imei = nil;
//    self._mobile = nil;
//    self._cell_id = nil;
//    self._gps = nil;
//    self._screenSize = nil;
//    self._os = nil;
//    self._osv = nil;
//    self._platform = nil;
//    self._chip = nil;
//    self._model = nil;
//    self._brand = nil;
//    self._operators = nil;
//    self._adSpace = nil;
//    self._channelSize = nil;
//    self._adWeight = nil;
//    self._adHeight = nil;
//    self._ct = nil;
//    self._type = nil;
//    self._mt = nil;
//    self._borderColor = nil;
//    self._bgColor = nil;
//    self._txtColor = nil;
//    self._lang = nil;
//    self._output = nil;
//    self._encrypt = nil;
//    self._testMode = nil;
//    self._database = nil;
//    self._access = nil;
//    self._bid = nil;
//    self._headerDomain = nil;
//    self._adType = nil;
//    self.adid = nil;
//    self._test = nil;
//    self._fmt = nil;
//    self._cs = nil;
//    
//    if (_orientationStatus) {
//        [_orientationStatus release];
//        _orientationStatus = nil;
//    }
//    
//    if (adShowingJumpLink) {
//        [adShowingJumpLink release];
//        adShowingJumpLink = nil;
//    }
//    if (_adToShowJumpLink) {
//        [_adToShowJumpLink release];
//        _adToShowJumpLink = nil;
//    }
//    if (_networkStatusStr) {
//        [_networkStatusStr release];
//        _networkStatusStr = nil;
//    }
//    if (_adToShow) {
//        [_adToShow release];
//        _adToShow = nil;
//    }
//    
//    if (pathOfDeClick) {
//        [pathOfDeClick release];
//        pathOfDeClick = nil;
//    }
//    if (pathOfRealClick) {
//        [pathOfRealClick release];
//        pathOfRealClick = nil;
//    }
//    clickCtlDic = nil;
//    clickCtlRepDic = nil;
//    
//    
//    
//    if (_documentDir) {
//        [_documentDir release];
//        _documentDir = nil;
//    }
//    if (_jumpLinkURL) {
//        [_jumpLinkURL release];
//        _jumpLinkURL = nil;
//    }
//    if (_pvURL) {
//        [_pvURL release];
//        _pvURL = nil;
//    }
//    if (_clkURL) {
//        [_clkURL release];
//        _clkURL = nil;
//    }
//    /* 取消监听sdk进入后台事件 */
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MaxMobSDKViewWillEnterBackground object:nil];
//    
//    /* 取消监听sdk后台唤醒事件 */
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MaxMobSDKViewWillEnterForeground object:nil];
//    [super dealloc];
//}
-(void)prepareNativeRequset
{
    [self setRequestInfo];
    [self setNetworkStatus];
}
-(void)prepareNativeRequsetWithStyle:(NSString *)style
{
    if ([style isEqualToString:@"style1"]) {
        [self prepareRequset];
    }
}
-(void)nativeAdClick
{
    adType = NativeAdType;
    [self prepareJumpPage];
}
-(void)prepareRequset
{
    if (!button&&!_adStyle) {
        button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _maxmobAdSDKView.frame.size.width, _maxmobAdSDKView.frame.size.height)];
        [button addTarget:self action:@selector(prepareJumpPage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self setRequestInfo];
    if([_adType isEqualToString:@"1"])
    {
        [self startTimerOfGetCurrentNetworkstatus];
    }
    [self setNetworkStatus];
    
    if (!networkStatus) {
        [_mmAdViewDelegate didAdReceived:nil withStatus:ErrorOfNetwork];
        _maxmobAdSDKView.hidden = YES;
    }

}

    
-(void)loadWebPage
{
    isHiddenBar = [[UIApplication sharedApplication] isStatusBarHidden];
//    NSLog(adType);
//    if ([adType isEqualToString:NativeAdType]) {
//        webViewController = [[TOWebViewController alloc] initWithURLString:_adToShowJumpLink];
//        UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//        while (topRootViewController.presentedViewController)
//        {
//            topRootViewController = topRootViewController.presentedViewController;
//        }
//        [ topRootViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
//        webViewController.delegate = self;
//        [webViewController release];
//        webViewController = nil;
////        [[NSNotificationCenter defaultCenter] postNotificationName:MaxMobSDKViewWillEnterBackground object:nil];
//    }else
//    {
        if (!_maxmobAdSDKView || !_maxmobAdSDKView.superview) {
            return;
        }else
        {
            webViewController = [[TOWebViewController alloc] initWithURLString:adShowingJumpLink];
            [_mmAdViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
            webViewController.delegate = self;
//            [webViewController release];
            webViewController = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:MaxMobSDKViewWillEnterBackground object:nil];
        }
    }
    
//}

/**
 * should be called to stop the timers
 */
- (void)sdkViewWillEnterBackground{
    if (timerOfShowAd) {
        [timerOfShowAd invalidate];
        timerOfShowAd = nil;
    }
    
    if (getNetWorkTimer) {
        [getNetWorkTimer invalidate];
        getNetWorkTimer = nil;
    }
    
    _maxmobAdSDKView.hidden = YES;
}

/**
 * should be called to restart the timers
 */
- (void)sdkViewWillEnterForeground{
    [self startTimerOfGetCurrentNetworkstatus];
    
    if (!networkStatus) {
        [_mmAdViewDelegate didAdReceived:nil withStatus:ErrorOfNetwork];
    }else {
        _maxmobAdSDKView.hidden = NO;
    }
}

-(void)startTimerOfGetCurrentNetworkstatus
{
    
    //这种方式的timer是不需要start的
    if (!getNetWorkTimer) {
        getNetWorkTimer = [NSTimer scheduledTimerWithTimeInterval:TIMEINTERVAL target:self selector:@selector(setNetworkStatus) userInfo:nil repeats:YES];
    }
}

-(void)setRequestInfo
{
    if (!DeviceInfoCollected)
    {
        //只收集一次
        _user_id = [NSString stringWithString:[UserInfo getIDFA]];
//      f._user_id = @"";
        _screenSize = [NSString stringWithString:[UserInfo getScreenResolutionSize]];
        _os = [NSString stringWithString:[UserInfo getOS]];
        _osv = [NSString stringWithString:[UserInfo getOSV]];
        _platform = [NSString stringWithString:[UserInfo getPlatform]];
        _brand = [NSString stringWithString:[UserInfo getBrand]];
        _cell_id = [NSString stringWithString:[UserInfo getCellID]];
//      f._gps = [NSString stringWithString:[UserInfo getGPS]];
        _gps = @"";
        _imei = [NSString stringWithString:[UserInfo getIMEI]];
        _lang = [NSString stringWithString:[UserInfo getLang]];
        _mobile = [NSString stringWithString:[UserInfo getMobile]];
        _model = [NSString stringWithString:[UserInfo getModel]];
        _operators = [NSString stringWithString:[UserInfo getOperators]];
        DeviceInfoCollected = YES;
        //不收集数据
        _imsi = [NSString stringWithString:[UserInfo getIMSI]];
        _chip = [NSString stringWithString:[UserInfo getChip]];
        //写死数据
        _mt = @"1";
        if ([[UserInfo getModel] isEqualToString:@"Simulator"])
        {
            _test = @"1";
        }else{
            _test = @"0";
        }
        _fmt = @"1";
        _cs = @"0";
    }
    if (self.userKey) {
        NSArray *userArray = [self.userKey componentsSeparatedByString:@"|"];
        _app_id = [NSString stringWithString:[userArray objectAtIndex:1]];
        _publish_id = [NSString stringWithString:[userArray objectAtIndex:0]];
        _adSpace = [NSString stringWithString:[userArray objectAtIndex:2]];
        _adType = [NSString stringWithString:[userArray objectAtIndex:3]];
//        self._channelSize = [self getChannelSize:(NSString*)_adType];
        _adWeight = [self getAdWightWithType:_adType];
        _adHeight = [self getAdHeightWithType:_adType];
        _type = @"";
        _database = DATABASE;
        self._headerDomain = HEADERDOMAIN;
       
    }else {
        [_mmAdViewDelegate didAdReceived:nil withStatus:ErrorOfWrongID];
    }
    //设置和广告相关的信息，是可能变化的信息
    _dist_id = [NSString stringWithString:[UserInfo getDistID]];
    _output = [NSString stringWithString:[UserInfo getOutput]];
    _encrypt = [NSString stringWithString:[UserInfo getEncrypt]];
    _testMode = [NSString stringWithString:[UserInfo getTestMode]];
    _bid = [NSString stringWithString:[UserInfo getBundleID]];
    //不收集数据
   _ct = [UserInfo getCt];
   _borderColor = [NSString stringWithString:[UserInfo getBorderColor]];
   _bgColor = [NSString stringWithString:[UserInfo getBgColor]];
   _txtColor = [NSString stringWithString:[UserInfo getTxtColor]];
}

-(NSString *)getAdWightWithType:(NSString *)adtype
{
    NSUInteger screenScale = [UIScreen mainScreen].scale;
    if ([adtype isEqualToString:@"1"])
    {
        if (320 == _maxmobAdSDKView.frame.size.width && 50 == _maxmobAdSDKView.frame.size.height) {
            if (2 == screenScale) {// retina
                return @"640";
            } else {
                return @"320";
            }
        } else if (768 == _maxmobAdSDKView.frame.size.width && 100 == _maxmobAdSDKView.frame.size.height) {
            return @"1280";
        }
    }else if ([adtype isEqualToString:@"2"])
    {
        return @"1200";
    }else if ([adtype isEqualToString:@"3"])
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if ([_orientationStatus isEqualToString:@"portrait"]) {
                return @"640";
            }else if ([_orientationStatus isEqualToString:@"landscape"])
            {
                return @"1136";
            }
            
        }else
        {
            if ([_orientationStatus isEqualToString:@"portrait"]) {
                return @"1536";
            }else if ([_orientationStatus isEqualToString:@"landscape"])
            {
                return @"2048";
            }
        }
    }else if ([adtype isEqualToString:@"4"])
    {
        return @"0";
    }
    else
    {
        return nil;
    }
    return nil;
}
-(NSString *)getChannelSize:(NSString *)adtype
{
    NSUInteger screenScale = [UIScreen mainScreen].scale;
    if ([adtype isEqualToString:@"1"])
    {
        if (320 == _maxmobAdSDKView.frame.size.width && 50 == _maxmobAdSDKView.frame.size.height) {
            if (2 == screenScale) {// retina
                return @"100|640";
            } else {
                return @"50|320";
            }
        } else if (768 == _maxmobAdSDKView.frame.size.width && 100 == _maxmobAdSDKView.frame.size.height) {
            return @"200|1280";
        }
    }else if ([adtype isEqualToString:@"2"])
    {
        return @"1000|1200";
    }else if ([adtype isEqualToString:@"3"])
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if ([_orientationStatus isEqualToString:@"portrait"]) {
                return @"1136|640";
            }else if ([_orientationStatus isEqualToString:@"landscape"])
            {
                return @"640|1136";
            }
            
        }else
        {
            if ([_orientationStatus isEqualToString:@"portrait"]) {
                return @"2048|1536";
            }else if ([_orientationStatus isEqualToString:@"landscape"])
            {
                return @"1536|2048";
            }
        }
    }else if ([adtype isEqualToString:@"4"])
    {
        return @"0|0";
    }
    else
    {
        return nil;
    }
    return nil;
}
- (NSString *)getAdHeightWithType:(NSString*) adtype
{
    NSUInteger screenScale = [UIScreen mainScreen].scale;
    if ([adtype isEqualToString:@"1"])
    {
        if (320 == _maxmobAdSDKView.frame.size.width && 50 == _maxmobAdSDKView.frame.size.height) {
            if (2 == screenScale) {// retina
                return @"100";
            } else {
                return @"50";
            }
        } else if (768 == _maxmobAdSDKView.frame.size.width && 100 == _maxmobAdSDKView.frame.size.height) {
            return @"200";
        }
    }else if ([adtype isEqualToString:@"2"])
    {
        return @"1000";
    }else if ([adtype isEqualToString:@"3"])
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if ([_orientationStatus isEqualToString:@"portrait"]) {
                return @"1136";
            }else if ([_orientationStatus isEqualToString:@"landscape"])
            {
                return @"640";
            }
            
        }else
        {
            if ([_orientationStatus isEqualToString:@"portrait"]) {
                return @"2048";
            }else if ([_orientationStatus isEqualToString:@"landscape"])
            {
                return @"1536";
            }
        }
    }else if ([adtype isEqualToString:@"4"])
    {
        return @"0";
    }
    else
    {
        return nil;
    }
    return nil;
}

//获取网络类型
- (void)setNetworkStatus{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    MaxMobReachability *maxmobReachability = [MaxMobReachability reachabilityForInternetConnection];
    MaxMobNetworkStatus state = [maxmobReachability currentReachabilityStatus];
    NSInteger version = [[[UIDevice currentDevice] systemVersion] integerValue];
    switch (state) {
        case MaxMobReachableViaWiFi:
            networkStatus = YES;
            _networkStatusStr = @"yes";
            _access = @"1";
            break;
        case MaxMobReachableViaWWAN:
            
            if (version >= 7)
            {
                /*
                 CTRadioAccessTechnologyGPRS         //介于2G和3G之间，也叫2.5G ,过度技术
                 CTRadioAccessTechnologyEdge         //EDGE为GPRS到第三代移动通信的过渡，EDGE俗称2.75G
                 CTRadioAccessTechnologyWCDMA
                 CTRadioAccessTechnologyHSDPA            //亦称为3.5G(3?G)
                 CTRadioAccessTechnologyHSUPA            //3G到4G的过度技术
                 CTRadioAccessTechnologyCDMA1x       //3G
                 CTRadioAccessTechnologyCDMAEVDORev0    //3G标准
                 CTRadioAccessTechnologyCDMAEVDORevA
                 CTRadioAccessTechnologyCDMAEVDORevB
                 CTRadioAccessTechnologyeHRPD        //电信使用的一种3G到4G的演进技术， 3.75G
                 CTRadioAccessTechnologyLTE          //接近4G
                 */
                CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
                NSString *mConnectType = [[NSString alloc] initWithFormat:@"%@",info.currentRadioAccessTechnology];
                if([mConnectType isEqualToString:CTRadioAccessTechnologyGPRS] || [mConnectType isEqualToString:CTRadioAccessTechnologyEdge] ){
                    networkStatus = YES;
                    _networkStatusStr = @"yes";
                    _access = @"2";
                }else if ([mConnectType isEqualToString: CTRadioAccessTechnologyCDMA1x] ||[mConnectType isEqualToString: CTRadioAccessTechnologyCDMAEVDORev0 ]||[mConnectType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] || [mConnectType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||[mConnectType isEqualToString:CTRadioAccessTechnologyeHRPD] || [mConnectType isEqualToString:CTRadioAccessTechnologyHSDPA] ||[mConnectType isEqualToString: CTRadioAccessTechnologyHSUPA]){
                    networkStatus = YES;
                    _networkStatusStr = @"yes";
                    _access = @"3";
                }else if ([mConnectType isEqualToString:CTRadioAccessTechnologyLTE])
                {
                    networkStatus = YES;
                    _networkStatusStr = @"yes";
                    _access = @"4";
                }else{
                    _access = @"0";
                    [_mmAdViewDelegate didAdReceived:nil withStatus:ErrorOfNetwork];
                    _maxmobAdSDKView.hidden = YES;
                }
            }else if (version<7)
            {
                networkStatus = YES;
                _networkStatusStr = @"yes";
                _access = @"2";
            }
            
            break;
        case MaxMobNotReachable:
        default:
            _access = @"0";
            [_mmAdViewDelegate didAdReceived:nil withStatus:ErrorOfNetwork];
            _maxmobAdSDKView.hidden = YES;
            break;
    }
    [self requestAd];
//    [pool release];
    
}

//请求广告
-(void)requestAd
{
    [self setRequstString];
    //**********此处应添加返回信息*****
    MaxMobprintfTestLogs([self class], [@"" stringByAppendingFormat:@"request string is no header: %@", requestString]);
    
    if(!requestString)
    {
        return;
    }
    NSData *requestData = [requestString dataUsingEncoding:enType];
//    [requestString release];
    requestString = nil;
    
    //对数据进行64位加密
    NSString *urlStringAfter64 = [NSString stringWithString:[MaxMobBase64 encode:requestData]];
    //对加密后的链接，拼接上头URL
    NSMutableString *headerUrl = [[NSMutableString alloc] initWithString:_headerDomain];
    [headerUrl appendString:urlStringAfter64];
    //**********此处应添加返回信息*****
    MaxMobprintfTestLogs([self class], [@"" stringByAppendingFormat:@"request string is: %@", headerUrl]);
    //发送请求
    [self sendRequest: headerUrl];
    
}

//设置请求字符串
-(void)setRequstString
{
    //刷新gps信息
//    self._gps = [NSString stringWithString:[UserInfo getGPS]];
    if (requestString) {
//        [requestString release];
        requestString = nil;
    }
    requestString = [[NSMutableString alloc] init];
    /**
    //对接SSP时请求广告字符串
     * pid = _publish_id    //开发者ID
     * mid = _app_id        //媒体ID（appID）
     * spid = _adSpace      //广告位ID
     * mt = _mt             //媒体类型
     * w = _adWeight        //广告位宽度
     * h = _adHeight        //广告位高度
     * dt = _platform       //设备类型
     * ct = _operators      //运营商类型
     * nt = _access         //联网方式
     * ver = _version       //SDK版本号
     * imei = _imei         //设备IMEI
     * idfa = _user_id      //设备IDFA
     * mac = _imsi          //设备Mac
     * os = _os             //操作系统
     * osv = _osv           //操作系统版本号
     * gps = _gps           //GPS坐标
     * dm = _model          //设备型号
     * db = _brand          //设备品牌
     * lang = _lang         //系统语言
     * test = _test         //是否测试
     * fmt = _fmt           //支持响应格式
     * cs = _cs             //是否支持cookie
     */
 
    /*
    //for ande
    [requestString appendFormat:@"ai=%@&pi=%@&di=%@&sn=%@&si=%@&im=%@&m=%@&ci=%@&g=%@&ss=%@&os=%@&plf=%@&ch=%@&mo=%@&mb=%@&op=%@&c=%@&s=%@&ct=%@&cht=%@&bc=%@&bg=%@&tc=%@&ul=%@&t=%@&e=%@&tm=%@&d=%@&n=%@&v=%@", _app_id, _publish_id, _dist_id, _user_id, _imsi, _imei, _mobile, _cell_id, _gps, _screenSize, _os, _platform, _chip, _model, _brand, _operators, _adSpace, _channelSize, _ct, _type, _borderColor, _bgColor, _txtColor, _lang, _output, _encrypt, _testMode, _database, _access, _version];
     */
    //for ssp
    [requestString appendFormat:@"pid=%@&mid=%@&spid=%@&mt=%@&w=%@&h=%@&dt=%@&ct=%@&nt=%@&bid=%@&imei=%@&idfa=%@&mac=%@&os=%@&osv=%@&gps=%@&dm=%@&db=%@&lang=%@&test=%@&fmt=%@&cs=%@",_publish_id,_app_id,_adSpace,_mt,_adWeight,_adHeight,_platform,_operators,_access,_bid,_imei,_user_id,_imsi,_os,_osv,_gps,_model,_brand,_lang,_test,_fmt,_cs];
     //发布时需禁掉log信息
}
// 发送请求
-(void)sendRequest:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setTimeoutInterval:3.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:MaxMobiOSSDKVersion forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
    NSInteger version = [[[UIDevice currentDevice] systemVersion] integerValue];
    if ((![_adType isEqualToString:@"3"] && version >= 5) || self.isRTSplash) {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
//            [request release];
            if (!data && !_adStyle) {
                if ([_adType isEqualToString:@"2"])
                {
                     _maxmobAdSDKView.hidden = YES;
                }
    
               [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:ErrorOfNetwork];
//                _maxmobAdSDKView = nil;
                return;
            }
            
            //增加分析response
            error = [self handleReponseOfReq:resp];
            if (error != nil) {
                return;
            }
            
            //对请求结果进行分析
            if (!self.isRTSplash)//判断是否缓存开屏
            {
                //非缓存开屏下，正常传入数据
                error = [self handleResultOfReq:data];
            }else
            {
                //将数据写入缓存
                NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *path=[paths objectAtIndex:0];
                NSString *Json_path=[path stringByAppendingPathComponent:@"DataFile.txt"];
                //==写入文件
                NSLog(@"%@",[data writeToFile:Json_path atomically:YES] ? @"Save RTSplash Ad Succeed   ^_^ ":@"Save RTSplash Ad Failed  T_T");
                
                //解析
                NSString *jsonAfterBase64 = [self jsonDataBase64Decoded:data];
                //transform json data to a dictionary
                NSDictionary *jsonDic = [self parseJSONToDic:jsonAfterBase64];
                
                //enumrate the keys in the jsonDic
                NSDictionary *jsonDicAfterEnum = [self keyEnum:jsonDic];
                // 下载图片
                NSString *linkOfImg = [MaxMobJsonDicAnalysis getImageLinkString:jsonDicAfterEnum];
                [ad useLocalCache:linkOfImg json:jsonDicAfterEnum];
            }
            
            if (error != nil) {
                return;//need to add code
            }
        }];
    }else {
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//        [request release];
        if (!data) {
            [_maxmobAdSDKView removeFromSuperview];
            _maxmobAdSDKView = nil;
//            return;
        }
        
        //增加分析response
        error = [self handleReponseOfReq:response];
        if (error != nil) {
            return;
        }
        
        //对请求结果进行分析
        error = [self handleResultOfReq:data];
        if (error != nil) {
            return;//need to add code
        }
        
    }
    
}
-(void)sendReport:(NSArray *)urlArray
{
    if(!urlArray)
    {
        return;
    }
    for (int i = 0; i<urlArray.count; i++) {
        NSURL *url = [NSURL URLWithString:urlArray[i]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
        [request setTimeoutInterval:3.0];
        [request setHTTPMethod:@"GET"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        }];
    }

}
- (id)handleReponseOfReq:(NSHTTPURLResponse*)_urlResponse{
    NSDictionary *headerDic = [_urlResponse allHeaderFields];
    NSInteger statusCodeInt = [_urlResponse statusCode];
    NSString *localStr = [NSHTTPURLResponse localizedStringForStatusCode:[_urlResponse statusCode]];
    
    MaxMobprintfDebugLogs([self class], [@"request response is: " stringByAppendingFormat:@"%@\n allHeaderFields is: %@ \n statusCode is: %i \n localizedString is: %@", _urlResponse, headerDic, statusCodeInt,localStr]);
    //需要增加response分析
    if (statusCodeInt == 200) {// 200 = ok
        return nil;
    } else {
//        [_maxmobAdSDKView removeFromSuperview];
         MaxMobcatchErrors(@"MaxMob ad", [@"Error code is: " stringByAppendingFormat:@"%@", ErrorOfNetwork]);
        [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:ErrorOfNetwork];
        _maxmobAdSDKView.hidden = YES;
        [_maxmobAdSDKView removeFromSuperview];
        return @"not ok!";
    }
}

- (id)handleResultOfReq:(NSData *)result
{

// SSP
//    NSError *error;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:nil];
    NSDictionary *jsonDicAfterEnum = [self keyEnum:jsonDic];
    [self prepareAd:jsonDicAfterEnum];
    //这里分析完成后，如果有错误就返回错误，如果没有错误就返回nil,需要增加处理结果的判断
    return nil;
}
- (NSString*)jsonDataBase64Decoded:(NSData*)jsonData{
    NSString *jsonString  = [[NSString alloc]initWithData:jsonData
                                                 encoding:enType];
    //对请求后的sting类型数据进行base64解密
    NSData *decodedData = [MaxMobBase64 decode:jsonString];
    
    NSString *decodedJSONString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    MaxMobprintfDebugLogs([self class], [@"jsonString is: " stringByAppendingFormat:@"%@, decodedJSONString is: %@", jsonString, decodedJSONString]);
//    [jsonString release];
    
    return decodedJSONString;
}
- (NSDictionary*)parseJSONToDic:(NSString*)decodedJSONString{
    //解析JSON字符串
    NSArray *list1 = [ decodedJSONString
                      componentsSeparatedByString:@"<imob>"];
    NSString *str = [list1 componentsJoinedByString:@""];
    list1 = nil;
    NSArray *list = [str componentsSeparatedByString:@"</imob>"];
    NSString *json_string = [list componentsJoinedByString:@""];
    list = nil;
    
    MaxMobSBJSON *json = [[MaxMobSBJSON alloc] init];
    
    NSDictionary *dictionary = [json AYobjectWithString:json_string error:nil];
    
//    [json release];
    return dictionary;
}
- (NSDictionary*)keyEnum:(NSDictionary*)jsonDic{

    //***** SSP *****
    NSString *admid = [jsonDic objectForKey:@"admid"];
    NSDictionary *adDetail = [jsonDic objectForKey:@"addetail"];
    NSMutableDictionary *jsonDicForSSP = [[NSMutableDictionary alloc]init];
    [jsonDicForSSP setValue:admid forKey:@"ad"];
    [jsonDicForSSP addEntriesFromDictionary:adDetail];
    return jsonDicForSSP;
}


//准备广告
-(void)prepareAd:(NSDictionary *)json
{
    isPrepareAdOK = NO;
    ad.adToShow = _adToShow;
    ad.documentDir = _documentDir;
    ad.networkStatus = _networkStatusStr;
//    if (!_maxmobAdSDKView)
//    {
//        return;
//    }else
//    {
        if ([[MaxMobJsonDicAnalysis getAdId:json] isEqualToString:@"0"])
        {
            MaxMobcatchErrors(_maxmobAdSDKView, [@"" stringByAppendingFormat:@"%@", ErrorOfEmptyAd]);
            [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:ErrorOfEmptyAd];
            if ([_adType isEqualToString:@"2"])
            {
                 _maxmobAdSDKView.hidden = YES;
                _maxmobInterstitialAdView.isReadly = NO;
            }
            _maxmobAdSDKView.hidden = YES;
            _maxmobAdSDKView = nil;
            return;
        }
        adType = [MaxMobJsonDicAnalysis getAdType:json];
        mediaType = [MaxMobJsonDicAnalysis getMtType:json];
    CGRect frame;
    if (![adType isEqualToString:NativeAdType]) {
       frame  = CGRectMake(0, 0, _maxmobAdSDKView.frame.size.width, _maxmobAdSDKView.frame.size.height);
    }
    
    
        if ([adType isEqualToString:BannerAdType] && [_adType isEqualToString:@"1"] )
        {
            if ([mediaType isEqualToString:@"32"]) {
                isPrepareAdOK = [ad prepareMrBannerAd:json frame:frame];
            }
            isPrepareAdOK = [ad prepareBannerAd:json ctrlFrame:frame Cache:isCache entype:enType];
        }else if ([adType isEqualToString:InterstitialAdType]&& [_adType isEqualToString:@"2"])
        {
            isPrepareAdOK = [ad prepareInterstitialAd:json ctrlFrame:frame Cache:isCache entype:enType];
        }else if ([adType isEqualToString:SplashAdType]&& [_adType isEqualToString:@"3"])
        {
            isPrepareAdOK = [ad prepareSplashAd:json ctrlFrame:frame Cache:isCache entype:enType];
        }else if ([adType isEqualToString:NativeAdType])
        {
            NSString *linkString = [MaxMobJsonDicAnalysis getLinkString:json];
            AdAction *adAction;
            adAction = [[AdAction alloc]init];
//            adShowingLinkType = [MaxMobJsonDicAnalysis getLinkType:json];
            if (![adAction checkAdToShowLinkType:adShowingLinkType linkStr:linkString json:json entype:enType])
            {
                //                [bannerAdView release];
                //                bannerAdView = nil;
                //                return NO;
            }
            _adToShowJumpLink =adAction.adToShowJumpLink;
            if (_adStyle == nil) {
                NativeAdData * nativeAdData  = [[NativeAdData alloc]init];
                nativeAdData.adTitle = [MaxMobJsonDicAnalysis getTitleString:json];
                nativeAdData.adBrief = [MaxMobJsonDicAnalysis getContentString:json];
                nativeAdData.adIcon = [MaxMobJsonDicAnalysis getIconLinkString:json];
                nativeAdData.adMedia = [MaxMobJsonDicAnalysis getImageLinkString:json];
                nativeAdData.adActionText = [MaxMobJsonDicAnalysis getLinkType:json];
                adShowingLinkType = [MaxMobJsonDicAnalysis getLinkType:json];
                
                [_nativeDelegate maxmobNativeAdLoadSuccess:nativeAdData];
                return;
            }else
            {
                UIView * adView = [self creatNativeAdViewWithStyle:_adStyle json:json];
                _adToShowLinkType = [MaxMobJsonDicAnalysis getLinkType:json];
                [_nativeDelegate maxmobNAtiveAdViewWithStyleLoadSuccess:adView];
//                return;
            }
           
        }
        else
        {
            [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:ErrorOfUnknown];
            [_maxmobAdSDKView removeFromSuperview];
            return;
        }
    if (![adType isEqualToString:NativeAdType]) {
        _adToShowJumpLink = ad.adToShowJumpLink;
        _adToShowLinkType = ad.adToShowLinkType;
        pvURL = [MaxMobJsonDicAnalysis getPvURlArray:json];
        clkURL = [MaxMobJsonDicAnalysis getClkURLArray:json];
        self.adid =[MaxMobJsonDicAnalysis getAdId:json];
        if (isPrepareAdOK) {
            _adToShow = ad.adToShow;
            if ([adType isEqualToString:BannerAdType])
            {
                [self timerOfShowAd];
            }else if ([adType isEqualToString:InterstitialAdType])
            {
                [self showInstlAd];
            }else if ([adType isEqualToString:SplashAdType])
            {
                [self startSplash];
            }
        }else{
            [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:@"prepareAd fail"];
            self.instlAdIsPrepare = NO;
            _maxmobAdSDKView.hidden = YES;
        }
    }
    
//    }
}
//根据style创建native Ad View
- (id)creatNativeAdViewWithStyle:(NSString *)style json:(NSDictionary *)json
{
    //add ad view
    UIView *adView;
    if ([style isEqualToString:@"Style1"]) {
        //add background view
        float adWidth = CGRectGetWidth([ UIScreen mainScreen ].bounds)-10;
        adView = [[UIView alloc] initWithFrame:CGRectMake(5, 5,adWidth,adWidth/5*3.8)];
        [adView setBackgroundColor:[UIColor grayColor]];
        //add icon view
        UIImageView *adIconView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        adIconView.image = [self loadImageWithURL:[MaxMobJsonDicAnalysis getIconLinkString:json]];
        [adView addSubview:adIconView];
        //add title label
        UILabel *adTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 5, 200, 20)];
        adTitleLabel.text = [MaxMobJsonDicAnalysis getTitleString:json];
        [adView addSubview:adTitleLabel];
        //add brief label
        UILabel *adBriefLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 25, 250, 17)];
        adBriefLabel.text = [MaxMobJsonDicAnalysis getContentString:json];
        [adView addSubview:adBriefLabel];
        //add media view
        UIImageView *adMediaView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 55, adWidth-20, adWidth/5*3-40)];
        adMediaView.image = [self loadImageWithURL:[MaxMobJsonDicAnalysis getImageLinkString:json]];
        [adView addSubview:adMediaView];
        //add action button
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        actionButton.frame = CGRectMake(adWidth-80, adWidth/5*3.8-25, 80, 20);
        [actionButton setTitle:[MaxMobJsonDicAnalysis getLinkType:json] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(nativeAdClick) forControlEvents:UIControlEventTouchUpInside];
        [adView addSubview:actionButton];
    }else if ([style isEqualToString:@"Style2"])
    {
        //add background view
        float adWidth = CGRectGetWidth([ UIScreen mainScreen ].bounds)-10;
        adView = [[UIView alloc] initWithFrame:CGRectMake(5, 5,adWidth,adWidth/5)];
        [adView setBackgroundColor:[UIColor grayColor]];
        //add icon view
        UIImageView *adIconView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
        adIconView.image = [self loadImageWithURL:[MaxMobJsonDicAnalysis getIconLinkString:json]];
        [adView addSubview:adIconView];
        //add title label
        UILabel *adTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 20)];
        adTitleLabel.text = [MaxMobJsonDicAnalysis getTitleString:json];
        [adView addSubview:adTitleLabel];
        //add brief label
        UILabel *adBriefLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 35, 250, 17)];
        adBriefLabel.text = [MaxMobJsonDicAnalysis getContentString:json];
        [adView addSubview:adBriefLabel];
        //add action button
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        actionButton.frame = CGRectMake(adWidth-70, adWidth/5-25, 80, 20);
        [actionButton setTitle:[MaxMobJsonDicAnalysis getLinkType:json] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(nativeAdClick) forControlEvents:UIControlEventTouchUpInside];
        [adView addSubview:actionButton];
    }else if ([style isEqualToString:@"Style3"])
    {
        //add background view
        float adWidth = CGRectGetWidth([ UIScreen mainScreen ].bounds)-10;
        adView = [[UIView alloc] initWithFrame:CGRectMake(5, 5,adWidth/2.5,adWidth/5*3)];
        [adView setBackgroundColor:[UIColor grayColor]];
        //add media view
        UIImageView *adMediaView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, adWidth/2.5, adWidth/5*3)];
        adMediaView.image = [self loadImageWithURL:[MaxMobJsonDicAnalysis getImageLinkString:json]];
        [adView addSubview:adMediaView];
        //add title background
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, adWidth/5*3-25,adWidth/2.5,25)];
        [bg setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.500]];
        [adView addSubview:bg];
        //add title label
        UILabel *adTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, adWidth/5*3-25, 200, 20)];
        adTitleLabel.text = [MaxMobJsonDicAnalysis getTitleString:json];
        adTitleLabel.textColor = [UIColor whiteColor];
        [adView addSubview:adTitleLabel];
        //add action button
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        actionButton.frame = CGRectMake(5, 5,adWidth/2.5,adWidth/5*3);
        [actionButton addTarget:self action:@selector(nativeAdClick) forControlEvents:UIControlEventTouchUpInside];
        [adView addSubview:actionButton];
    }
    return adView;
}
- (id)loadImageWithURL:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSData *_result = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:_result];
    return image;
}
- (void)timerOfShowAd
{
    if (!timerOfShowAd) {
        timerOfShowAd = [NSTimer scheduledTimerWithTimeInterval:TIMEINTERVAL target:self selector:@selector(showAd) userInfo:nil repeats:YES];
        [self showAd];
    }
}
-(void)showAd
{
    @autoreleasepool {
        if (!_maxmobAdSDKView || !_mmAdViewDelegate || !_mmAdViewController) {
        }else{
            if (adShowing) {
                [adShowing removeFromSuperview];
                adShowing = nil;
            }
            if (!_adToShow || !_adToShowJumpLink ) {
                // 异常处理，空广告或者不识别的广告类型
                // 这时候_maxmobAdSDKView不为空，且显示的是上一幅广告，需要隐藏广告控件
                _maxmobAdSDKView.hidden = YES;
                return;
            }
            adShowing = _adToShow;
//            [_adToShow release];
            _adToShow = nil;
            
            if (adShowingJumpLink) {
//                [adShowingJumpLink release];
            }
            adShowingJumpLink = _adToShowJumpLink;
//            [_adToShowJumpLink release];
            _adToShowJumpLink = nil;// 导表后临时表一定要置空
            
            if (adShowingLinkType) {
//                [adShowingLinkType release];
            }
            adShowingLinkType = _adToShowLinkType;
//            [_adToShowLinkType release];
            _adToShowLinkType = nil;// 导表后临时表一定要置空
            
            if (adShowing_date_id) {
//                [adShowing_date_id release];
            }
            adShowing_date_id = date_id;
//            [date_id release];
            date_id = nil;// 这里其实导表了，所以必须置空
            
            if (showingReportStr) {
//                [showingReportStr release];
            }
            showingReportStr = toShowReportStr;
//            [toShowReportStr release];
            toShowReportStr = nil;// 这里其实导表了，所以必须置空
            
            //设置随机动画
            _maxmobAdSDKView.clipsToBounds = YES;
            [Transition setRandomAnimation: _maxmobAdSDKView];
            [_maxmobAdSDKView addSubview: adShowing];
//            [adShowing release];
            [_maxmobAdSDKView setNeedsDisplay];
            [_maxmobAdSDKView addSubview:button];
            [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:SuccessShowAd];
            [self sendReport:pvURL];
            reportAd = nil;
            if (!networkStatus || !isPrepareAdOK) {// 无网络
                _maxmobAdSDKView.hidden = YES;
            }else {
                _maxmobAdSDKView.hidden = NO;
            }
        }
    }
}

-(void)closeInstlButClick
{
    _maxmobAdSDKView.hidden = YES;
    [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:@"close instertitial ad"];
    self.instlAdIsPrepare = NO;
    //删除缓存，重新请求广告
    [_maxmobAdSDKView removeFromSuperview];
    _maxmobAdSDKView = nil;
    _maxmobInterstitialAdView = nil;
}

-(void)showInstlAd
{
    @autoreleasepool {
        if (!_maxmobAdSDKView || !_mmAdViewDelegate || !_mmAdViewController) {
        }else{
            if (adShowing) {
                [adShowing removeFromSuperview];
                adShowing = nil;
            }
            if (!_adToShow || !_adToShowJumpLink ) {
                // 异常处理，空广告或者不识别的广告类型
                // 这时候_maxmobAdSDKView不为空，且显示的是上一幅广告，需要隐藏广告控件
                _maxmobAdSDKView.hidden = YES;
                return;
            }
            adShowing = _adToShow;
//            [_adToShow release];
            _adToShow = nil;
            
            if (adShowingJumpLink) {
//                [adShowingJumpLink release];
            }
            adShowingJumpLink = _adToShowJumpLink;
//            [_adToShowJumpLink release];
            _adToShowJumpLink = nil;// 导表后临时表一定要置空
            
            if (adShowingLinkType) {
//                [adShowingLinkType release];
            }
            adShowingLinkType = _adToShowLinkType;
//            [_adToShowLinkType release];
            _adToShowLinkType = nil;// 导表后临时表一定要置空
            
            if (adShowing_date_id) {
//                [adShowing_date_id release];
            }
            adShowing_date_id = date_id;
//            [date_id release];
            date_id = nil;// 这里其实导表了，所以必须置空
            
            if (showingReportStr) {
//                [showingReportStr release];
            }
            showingReportStr = toShowReportStr;
//            [toShowReportStr release];
            toShowReportStr = nil;// 这里其实导表了，所以必须置空
            
            //add bg mask
//            UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth([ UIScreen mainScreen ].bounds),CGRectGetHeight([ UIScreen mainScreen ].bounds))];
//            [bg setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.500]];
//            [_maxmobInterstitialAdView addSubview:bg];
            
            
            [_maxmobInterstitialAdView addSubview: adShowing];
            //add close ad button
            closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            closeBtn.frame = CGRectMake(adShowing.frame.size.width-40, 0, 40, 40);
            NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MaxMobAdSDKBundle" ofType:@"bundle"]];
            NSString * image_url = [bundle pathForResource:@"closeBtn2" ofType:@"png"];
            UIImage *img =[UIImage imageWithContentsOfFile:image_url];
            [closeBtn setBackgroundImage:img forState:UIControlStateNormal];
            closeBtn.backgroundColor = [UIColor clearColor];
            [closeBtn addTarget:self action:@selector(closeInstlButClick) forControlEvents:UIControlEventTouchUpInside];
            [adShowing addSubview:button];
            [adShowing addSubview:closeBtn];
            
//            [adShowing release];
//            [closeBtn release];
            [_maxmobAdSDKView setNeedsDisplay];
            [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:InterstitialAdIsPrepareOk];
            self.instlAdIsPrepare = YES;
            _maxmobInterstitialAdView.hidden = YES;
        }
    }
}
-(void)clickShowInstlAd
{
    if (self.instlAdIsPrepare) {
        _maxmobInterstitialAdView.hidden = NO;
        
        [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:SuccessShowInterstitialAd];
        [self sendReport:pvURL];
    }else
    {
        [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:@"not prepare"];
        _maxmobInterstitialAdView.hidden = YES;
    }
    
}

-(void)startSplash{
    @autoreleasepool {
        if (!_maxmobAdSDKView || !_mmAdViewDelegate) {
        }else{
            if (adShowing) {
                [adShowing removeFromSuperview];
                adShowing = nil;
            }
            if (!_adToShow) {
                // 异常处理，空广告或者不识别的广告类型
                // 这时候_maxmobAdSDKView不为空，且显示的是上一幅广告，需要隐藏广告控件
                _maxmobAdSDKView.hidden = YES;
                return;
            }
            adShowing =_adToShow;
//            [_adToShow release];
            _adToShow = nil;
            
                        
            if (adShowing_date_id) {
//                [adShowing_date_id release];
            }
            adShowing_date_id = date_id;
//            [date_id release];
            date_id = nil;// 这里其实导表了，所以必须置空
            
            if (showingReportStr) {
//                [showingReportStr release];
            }
            showingReportStr = toShowReportStr;
//            [toShowReportStr release];
            toShowReportStr = nil;// 这里其实导表了，所以必须置空
            
            [_maxmobAdSDKView addSubview: adShowing];
            //add close ad button
            closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            closeBtn.frame = CGRectMake(_maxmobAdSDKView.frame.size.width-40, 0, 40, 40);
            NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MaxMobAdSDKBundle" ofType:@"bundle"]];
            NSString * image_url = [bundle pathForResource:@"closeBtn2" ofType:@"png"];
            UIImage *img =[UIImage imageWithContentsOfFile:image_url];
            [closeBtn setBackgroundImage:img forState:UIControlStateNormal];
            closeBtn.backgroundColor = [UIColor clearColor];
            [closeBtn addTarget:self action:@selector(closeSplash) forControlEvents:UIControlEventTouchUpInside];
//            [adShowing addSubview:button];
            [adShowing addSubview:closeBtn];
            
//            [adShowing release];
//            [closeBtn release];
            [_maxmobAdSDKView setNeedsDisplay];
            _maxmobAdSDKView.hidden = NO;
            [self performSelector:@selector(closeSplash) withObject:nil afterDelay:2.5f];
            [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:SuccessShowSplashAd];
            [self sendReport:pvURL];
        }
    }
}
#pragma mark -
#pragma mark - RTSplash

-(void)showRTSplashAd
{
    //传入缓存数据
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *Json_path=[path stringByAppendingPathComponent:@"DataFile.txt"];
    NSData *data=[NSData dataWithContentsOfFile:Json_path];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"DataFile.txt"];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    //在此解析数据准备广告
    if (blHave) {
        [self handleResultOfReq:data];
        //删除沙盒文件
        MaxMobprintfDebugLogs([self class], [@"check datafile: " stringByAppendingFormat:@"have"]);
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        if (blDele) {
            MaxMobprintfDebugLogs([self class], [@"check datafile: " stringByAppendingFormat:@"dele success"]);

        }else {
            MaxMobprintfDebugLogs([self class], [@"check datafile: " stringByAppendingFormat:@"dele fail"]);
        }
    }else
    {
         MaxMobprintfDebugLogs([self class], [@"check datafile: " stringByAppendingFormat:@"not have datafile"]);
        [_mmAdViewDelegate didAdReceived:_maxmobAdSDKView withStatus:@"not prepare"];
        _maxmobAdSDKView.hidden = YES;
    }
    
    
}
-(void)closeSplash
{
    _maxmobAdSDKView.hidden = YES;
    _maxmobAdSDKView = nil;
}

+(id)sendURL:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
//    NSHTTPURLResponse **urlResponse = nil;
//    NSError *error = nil;
    MaxMobprintfDebugLogs([self class],[ @"urlstring is: " stringByAppendingFormat:@"%@", urlString]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSData *_result = [NSData dataWithContentsOfURL:url];
    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//     {
//         NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
//         [request release];
//         if (!data) {
//             return;
//         }
//         
//         //增加分析response
//         error = [self handleReponseOfReq:resp];
//         if (error != nil) {
//             return;
//         }
//         if (data != nil) {
//             _result = data;
//             return ;
//         }
//     }
//     ];
//    NSData *_result = [NSURLConnection sendSynchronousRequest:request returningResponse:urlResponse error:&error];
//    NSString* resultStr= [[NSString alloc] initWithData:_result  encoding:NSASCIIStringEncoding];
//    if ([resultStr rangeOfString:@"404"].location != NSNotFound) {
//        return nil;
//    }
//    if (!_result) {
//        [request release];
//        return nil;
//    }
//    
//    [request release];
    return _result;
}

-(void)clickedReturnBtn{
    [[UIApplication sharedApplication] setStatusBarHidden:isHiddenBar];
    if (!_maxmobAdSDKView || !_mmAdViewDelegate || !_mmAdViewController) {
        return;
    } else {
//        [_mmAdViewDelegate willDismissScreen:_maxmobAdSDKView];
        //        [self sdkViewWillEnterForeground];// 重点观察对象
        // instead of [self sdkViewWillEnterForeground];
        [[NSNotificationCenter defaultCenter] postNotificationName:MaxMobSDKViewWillEnterForeground object:nil];
    }
}

/*
- (void)reportToDE:reportString{
    // 上报DE
    NSURL *url = [NSURL URLWithString:reportString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"SET"];
    
    int version = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (version >= 5) {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            static int tryTimes = 0;
            if (error != nil && tryTimes == 0) {
                [self reportToDE:reportString];
                tryTimes = 1;
            }else {
                return ;
            }
        }];
    }else {
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error != nil) {
            static int tryTimes = 0;
            if (error != nil && tryTimes == 0) {
                [self reportToDE:reportString];
                tryTimes = 1;
            }else {
                return ;
            }
        }
    }
    
    [request release];
}
 */
- (void)stop{
    if (getNetWorkTimer) {
        [getNetWorkTimer invalidate];
        getNetWorkTimer = nil;
    }
    if (timerOfShowAd) {
        [timerOfShowAd invalidate];
        timerOfShowAd = nil;
    }
    
    if (self.maxmobAdSDKView) {
        self.maxmobAdSDKView = nil;
    }
    
//    if (self.delegate) {
//        self.delegate = nil;
//    }
//    
//    if (self.controller) {
//        self.controller = nil;
//    }
}


#pragma mark -
#pragma mark - ad button callback method
-(void)prepareJumpPage
{
    @autoreleasepool {
        MaxMobprintfTestLogs([self class], [@"report string" stringByAppendingFormat:@": %@",adShowingJumpLink]);
//        if (!pathOfDeClick) {
            //如果为空，表示不控制.所以点击的时候这个可能为nil
            if ([adShowing_date_id isEqualToString:@""] || (!adShowing_date_id)) {//如果没有点击计数，则不用控制
                if ([WEB isEqualToString:adShowingLinkType]) {
                    
                    [self loadWebPage];
                    //点击上报
                    [self sendReport:clkURL];
                    [_mmAdViewDelegate onClicked:_maxmobAdSDKView toWhere:WEB];
                } else if([MARKET isEqualToString:adShowingLinkType]){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adShowingJumpLink]];
                    [_mmAdViewDelegate onClicked:_maxmobAdSDKView toWhere:MARKET];
                }
                return;
            }
//        }else
//        {
//            clickCtlDic = [NSMutableDictionary dictionaryWithContentsOfFile:pathOfDeClick];
//            if (!clickCtlDic) {
//                clickCtlDic = [[[NSMutableDictionary alloc] init] autorelease];
//            }
//            if (!pathOfRealClick) {
//                NSString *fileName = [NSString stringWithFormat:@"%i.realclick", day];
//                pathOfRealClick = [[NSString alloc] initWithString:[_documentDir stringByAppendingPathComponent:fileName]];
//            }
//            clickCtlRepDic = [NSMutableDictionary dictionaryWithContentsOfFile:pathOfRealClick];
//            if (!clickCtlRepDic) {
//                clickCtlRepDic = [[[NSMutableDictionary alloc] init] autorelease];
//            }
//            NSString *mac = [clickCtlDic objectForKey:adShowing_date_id];
//            int intMac = [mac intValue];
//            NSString *realClickStr = @"";
//            int realClickInt = 0;
//            realClickStr = [clickCtlRepDic objectForKey:adShowing_date_id];
//            realClickInt = [realClickStr intValue];
//            if (intMac == 0) {
//                if ([WEB isEqualToString:adShowingLinkType]) {
//                    [self loadWebPage];
//                    [_mmAdViewDelegate onClicked:_maxmobAdSDKView toWhere:WEB];
//                } else if([MARKET isEqualToString:adShowingLinkType]){
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adShowingJumpLink]];
//                    [_mmAdViewDelegate onClicked:_maxmobAdSDKView toWhere:MARKET];
//                }
//                
//            }else if(realClickInt >= intMac ){// 唯一计数生效，第二次以后的点击
//                if ([WEB isEqualToString:adShowingLinkType]) {
//                    if (adShowingJumpLink) {
//                        [adShowingJumpLink release];
//                    }
//                    adShowingJumpLink = [_jumpLinkURL retain];//直接跳转，不进行重定向
//                    //                [jumpLinkURL release];
//                    //                jumpLinkURL = nil;// 导表置空
//                    // 这里不能导表置空，因为不是临时表，后面仍然需要使用
//                    
//                    [self loadWebPage];
//                    [_mmAdViewDelegate onClicked:_maxmobAdSDKView toWhere:WEB];
//                } else if([MARKET isEqualToString:adShowingLinkType]){
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adShowingJumpLink]];
//                    [_mmAdViewDelegate onClicked:_maxmobAdSDKView toWhere:MARKET];
//                }
//            }else {//<= // 唯一计数生效，第一次点击
//                //计数加1
//                realClickInt++;
//                realClickStr = [[NSString alloc] initWithFormat:@"%i",realClickInt];
//                [clickCtlRepDic setObject:realClickStr forKey:adShowing_date_id];
//                [realClickStr release];
//                
//                
//                if ([WEB isEqualToString:adShowingLinkType]) {
//                    [self loadWebPage];
//                    [_mmAdViewDelegate onClicked:_maxmobAdSDKView toWhere:WEB];
//                } else if([MARKET isEqualToString:adShowingLinkType]){
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adShowingJumpLink]];//不是同步返回结果,有可能是异步打开url。这时返回值还是false.
//                    [self reportToDE:showingReportStr];
//                    // 这里不应该释放 showingReportStr，因为很可能会进入不只一次
//                    [_mmAdViewDelegate onClicked:_maxmobAdSDKView toWhere:MARKET];
//                }
//            }
//            [clickCtlRepDic writeToFile:pathOfRealClick atomically:YES];
//            MaxMobprintfTestLogs(@"after write real click path", [@"" stringByAppendingFormat:@"%@, dic: %@",pathOfRealClick, clickCtlRepDic]);
//        }
    }
}

#pragma mark -通知系统
void MaxMobcatchErrors(id object, id errorDescription){
    if (LogTagError) {
        NSLog(@"%@ catches error : %@", object, errorDescription);
    }
}

void MaxMobprintfDebugLogs(id object, id logDescription){
    if (LogTagDebug) {
        NSLog(@"%@:  %@", object, logDescription);
    }
}

void MaxMobprintfTestLogs(id object, id logDescription){
    if (LogTagTest) {
        NSLog(@"%@:  %@", object, logDescription);
    }
}

@end
