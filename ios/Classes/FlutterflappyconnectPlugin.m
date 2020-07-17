#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "FlutterflappyconnectPlugin.h"
#import "ReachabilityFlappy.h"


//整个插件
@interface FlutterflappyconnectPlugin ()<FlutterStreamHandler>

//消息event
@property(nonatomic,strong) FlutterEventChannel* eventChannel;
//消息发送
@property(nonatomic,strong) FlutterEventSink eventSink;
//host变化
@property (nonatomic) ReachabilityFlappy *hostReachability;
//网络类型变化
@property (nonatomic) ReachabilityFlappy *internetReachability;


@end


@implementation FlutterflappyconnectPlugin


//注册
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    
    //创建eventChannel
    FlutterEventChannel* eventChannel=[FlutterEventChannel eventChannelWithName:@"flutterflappyconnect_event"
                                                                binaryMessenger:[registrar messenger]];
    //channel
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutterflappyconnect"
                                     binaryMessenger:[registrar messenger]];
    //创建
    FlutterflappyconnectPlugin* instance = [[FlutterflappyconnectPlugin alloc] init];
    //保留参数
    instance.eventChannel=eventChannel;
    //设置
    [eventChannel setStreamHandler:instance];
    //开启监听
    [instance listenNetWorkingStatus];
    //添加
    [registrar addMethodCallDelegate:instance channel:channel];
}

-(void)listenNetWorkingStatus{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotificationFlappy object:nil];
    // 设置网络检测的站点
    //    NSString *remoteHostName = @"www.baidu.com";
    //    self.hostReachability = [ReachabilityFlappy reachabilityWithHostName:remoteHostName];
    //    [self.hostReachability startNotifier];
    //    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [ReachabilityFlappy reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

//changed
- (void) reachabilityChanged:(NSNotification *)note
{
    ReachabilityFlappy* curReach = [note object];
    [self updateInterfaceWithReachability:curReach];
}

//更新
- (void)updateInterfaceWithReachability:(ReachabilityFlappy *)reachability
{
    //消息发送
    if(_eventSink!=nil){
        _eventSink(@"");
    }
}

//移除
- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotificationFlappy
                                                  object:nil];
    _eventChannel=nil;
}


//消息
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getConnectionType" isEqualToString:call.method]) {
        result([self getNetconnType]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

//获取网络类型
- (NSString *)getNetconnType{
    
    NSString *netconnType = @"";
    NSString *netconnTypeMine = @"";
    
    ReachabilityFlappy *reach = [ReachabilityFlappy reachabilityWithHostName:@"www.baidu.com"];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {
            
            netconnType = @"no network";
            netconnTypeMine=@"6";
        }
            break;
            
        case ReachableViaWiFi:// Wifi
        {
            netconnType = @"Wifi";
            netconnTypeMine=@"5";
        }
            break;
            
        case ReachableViaWWAN:// 手机自带网络
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            
            NSString *currentStatus = info.currentRadioAccessTechnology;
            
            netconnTypeMine=@"4";
            
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                
                netconnTypeMine=@"0";
                netconnType = @"GPRS";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                
                netconnTypeMine=@"0";
                netconnType = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                
                netconnTypeMine=@"1";
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                
                netconnTypeMine=@"1";
                netconnType = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                
                netconnTypeMine=@"1";
                netconnType = @"3.5G HSUPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                
                netconnTypeMine=@"0";
                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                
                netconnTypeMine=@"1";
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                
                netconnTypeMine=@"1";
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                
                netconnTypeMine=@"1";
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                
                netconnTypeMine=@"1";
                netconnType = @"HRPD";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                
                netconnTypeMine=@"2";
                netconnType = @"4G";
            }
        }
            break;
            
        default:
            break;
    }
    
    return netconnTypeMine;
}


//事件传输被终止
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    //设置sink
    _eventSink = nil;
    return nil;
}
//事件传输开启
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
    //设置eventSink
    _eventSink = events;
    return nil;
}


@end
