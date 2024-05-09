//
//  ViewController.m
//  PasterSDK
//
//  Created by frank on 2023/1/30.
//

#import "ViewController.h"
#import "DeviceListViewController.h"
#import "MBProgressUtils.h"
#import "FlexPasterSDK.h"
#import "LookWaveVC.h"
#import "RealIndexVC.h"
#import "AudioHelper.h"

#define scanAction    @"scanBleDevice"                      ///扫描
#define stopScanAction    @"stopScan"                       ///停止扫描
#define connectAction    @"connect"                         ///连接
#define statusAction    @"isConnected"                      ///连接状态
#define closeConnectAction    @"closeDevice"                ///关闭连接
#define receiveAction    @"setRealDataListener"             ///接收数据
#define subDataAction    @"pickDataByPointStamp"            ///截取数据
#define rssiAction    @"getDeviceRssi"                      ///信号强度
#define batteryAction    @"getBattery"                      ///设备电量
#define isWearAction    @"isWearPatch"                      ///是否穿戴
#define getPosition    @"getPosition"                       ///计算体位
#define filterParamAction    @"setFilterParam"              ///滤波参数
#define startRecordAction    @"startRecord"                 ///开始记录
#define stopRecordAction    @"stopRecord"                   ///停止记录
#define addEventAction    @"addEvent"                       ///添加事件
#define signalQualityAction    @"signalQuality"             ///信号质量
#define deviceInfoAction    @"deviceInfo"                   ///设备信息
#define onlineStageAction    @"setSleepStageListener"       ///分期状态
#define lookWaveAction    @"lookWaveAction"                 ///查看波形
#define realIndexAction    @"realIndexAction"               ///实时指标
#define startMeditation    @"startMeditation"               ///开始冥想
#define closeMeditation    @"closeMeditation"               ///结束冥想
#define queryOfflineDataAction    @"queryOfflineDataAction" ///查询离线数据
#define mergeOfflineDataAction    @"mergeOfflineDataAction" ///合并离线数据
#define cancelOfflineDataAction  @"cancelOfflineDataAction" ///取消离线数据


#define AppKey @"rld77eb4ff82ee"
#define AppSecret @"00f7d66c9aa4480d8bb73599d82a8d8e"

#define equal(str1, str2) [str1 isEqualToString:str2]

static NSString *cellId = @"cellId";

@interface ViewController ()<ScanPasterDelegate, PasterConnectDelegate, RealTimeDataDelegate, PickDataDelegate, RecordDelegate, OnlineStageDelegate, MeditationDelegate, UITableViewDelegate, UITableViewDataSource, OfflineDataDelegate>

@property(nonatomic, strong) NSMutableArray<NSNumber *>* tempDataArray;
@property(nonatomic, strong) NSMutableArray<ApiModel *>* items;

///是否打开实时数据监听
@property(nonatomic, assign) BOOL isOpenReal;

///本地保存的 uuid，user，edfName， 例子中通过 userdefault，实际开发中，可以使用 数据库保存
@property(nonatomic, copy) NSString* savedUID;
@property(nonatomic, copy) NSString* savedUser;
@property(nonatomic, copy) NSString* savedEdfName;///文件名 非文件路径

@property(nonatomic, assign) BOOL hasOfflineData;

@property(nonatomic, strong) UILabel* tempLabel;

@property(nonatomic, assign) NSInteger disConnectedCnt;

@property(nonatomic, strong) AudioHelper *audioHelper;
@end

@implementation ViewController

- (NSMutableArray<ApiModel *> *) items {
    if (!_items) {
        
        _items = [NSMutableArray arrayWithArray:@[
            [[ApiModel alloc] initWithShowTitle:@"扫描" action:scanAction],
            [[ApiModel alloc] initWithShowTitle:@"停止扫描" action:stopScanAction],
            [[ApiModel alloc] initWithShowTitle:@"连接状态" action:statusAction],
            [[ApiModel alloc] initWithShowTitle:@"关闭连接" action:closeConnectAction],
            [[ApiModel alloc] initWithShowTitle:@"数据实时监听" action:receiveAction],
            [[ApiModel alloc] initWithShowTitle:@"截取数据（5s）" action:subDataAction],
            [[ApiModel alloc] initWithShowTitle:@"信号强度" action:rssiAction],
            [[ApiModel alloc] initWithShowTitle:@"设备电量" action:batteryAction],
            [[ApiModel alloc] initWithShowTitle:@"是否穿戴" action:isWearAction],
            [[ApiModel alloc] initWithShowTitle:@"计算体位" action:getPosition],
            [[ApiModel alloc] initWithShowTitle:@"滤波参数" action:filterParamAction],
            [[ApiModel alloc] initWithShowTitle:@"查询离线数据" action:queryOfflineDataAction],
            [[ApiModel alloc] initWithShowTitle:@"合并离线数据" action:mergeOfflineDataAction],
            [[ApiModel alloc] initWithShowTitle:@"取消离线数据合并" action:cancelOfflineDataAction],
            [[ApiModel alloc] initWithShowTitle:@"开始记录" action:startRecordAction],
            [[ApiModel alloc] initWithShowTitle:@"停止记录" action:stopRecordAction],
            [[ApiModel alloc] initWithShowTitle:@"睡眠记录中添加事件" action:addEventAction],
            [[ApiModel alloc] initWithShowTitle:@"信号质量" action:signalQualityAction],
//            [[Model alloc] initWithShowTitle:@"设备信息" action:deviceInfoAction],
            [[ApiModel alloc] initWithShowTitle:@"分期状态" action:onlineStageAction],
            [[ApiModel alloc] initWithShowTitle:@"查看波形" action:lookWaveAction],
            [[ApiModel alloc] initWithShowTitle:@"实时指标" action:realIndexAction],
            [[ApiModel alloc] initWithShowTitle:@"开始冥想" action:startMeditation],
            [[ApiModel alloc] initWithShowTitle:@"结束冥想" action:closeMeditation],
        ]];
        
    }
    
    
    return _items;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.textLabel.text = self.items[indexPath.row].showTitle;
    
    cell.detailTextLabel.text = self.items[indexPath.row].isAuthority ? @"已授权" : @"未授权";
    cell.detailTextLabel.textColor = self.items[indexPath.row].isAuthority ? [UIColor blackColor] : [UIColor redColor];
    
    ///查看波形默认提供，无需授权
    if ([self.items[indexPath.row].showTitle isEqualToString:@"查看波形"]) {
        cell.detailTextLabel.hidden = YES;
    }
    
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *action = self.items[indexPath.row].action;
    
    if ([action isEqualToString:scanAction]) {
        
        [self.navigationController pushViewController:[[DeviceListViewController alloc] init] animated:YES];
        
    }
    else  if ([action isEqualToString:stopScanAction]) {
        
        [self.navigationController pushViewController:[[DeviceListViewController alloc] init] animated:YES];
        
    }
    else  if ([action isEqualToString:connectAction]) {
        
        
    }
    else  if ([action isEqualToString:statusAction]) {
        
        BOOL state = [[FlexPasterSDK sharedInstance] isConnected];
        [MBProgressUtils showMsg:state ? @"已连接" : @"未连接" view:self.view];
        
    }
    else  if ([action isEqualToString:closeConnectAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        
        [[FlexPasterSDK sharedInstance] closeBleDevice];
        [MBProgressUtils showMsg:@"设备已断开" view:self.view];
        
    }
    else  if ([action isEqualToString:receiveAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        
        [[FlexPasterSDK sharedInstance] realDataListener:self];
        
    }
    else  if ([action isEqualToString:subDataAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
        [[FlexPasterSDK sharedInstance] pickupDataListener:self second:5];
        
    }
    else  if ([action isEqualToString:rssiAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
        NSInteger rssi = [[FlexPasterSDK sharedInstance] deviceRSSI];
        [MBProgressUtils showMsg:[NSString stringWithFormat:@"信号强度为%ld dBm", rssi] view:self.view];
    }
    else  if ([action isEqualToString:batteryAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
        NSUInteger battery = [[FlexPasterSDK sharedInstance] battery];
        [MBProgressUtils showMsg:[NSString stringWithFormat:@"设备电量为%ld %%", battery] view:self.view];
        
    }
    else  if ([action isEqualToString:isWearAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
        BOOL isWear = [[FlexPasterSDK sharedInstance] isWearPatch];
        [MBProgressUtils showMsg:isWear ? @"设备已穿戴" : @"设备未穿戴" view:self.view];
        
    }
    else  if ([action isEqualToString:getPosition]) {
        
        if (![self isConnected]) {
            return;
        }
        
        NSInteger position = [[FlexPasterSDK sharedInstance] calculatePosition];
        NSString *posiText = @"未知";
        if (position == 1) {
            posiText = @"仰卧";
        } else if (position == 2) {
            posiText = @"左侧位";
        } else if (position == 3) {
            posiText = @"俯卧";
        } else if (position == 4) {
            posiText = @"右侧位";
        } else if (position == 5) {
            posiText = @"立位";
        }
        
        [MBProgressUtils showMsg:[NSString stringWithFormat:@"体位：%@", posiText] view:self.view];
        
    }
    else  if ([action isEqualToString:filterParamAction]) {
        
        [[FlexPasterSDK sharedInstance] filterParam:4 hp:50 lp:5];
        [MBProgressUtils showMsg:[NSString stringWithFormat:@"已设置为order=4,hp=50,lp=5"] view:self.view];
        
    }
    else  if ([action isEqualToString:startRecordAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
        UserInfoModel *model = [[UserInfoModel alloc] init];
        model.birthday = @"2023-02-03";
        model.sex = @"M";//男性 M，女性 F
        model.name = @"ABCDE";
        model.deviceName = @"Flex-BM05-500020";
    
        [[FlexPasterSDK sharedInstance] startRecordWithUserInfo:model recordDelegate:self];
        
    }
    else  if ([action isEqualToString:stopRecordAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
        [[FlexPasterSDK sharedInstance] stopRecord];
        
    }
    else  if ([action isEqualToString:addEventAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
        long long startTimeStamp = [[NSDate date] timeIntervalSince1970]*1000*10;
        long long duration = 1000*10;

        [[FlexPasterSDK sharedInstance] addEdfEventWithStartTime:startTimeStamp duration:duration eventContent:@"test event"];
        
    }
    else  if ([action isEqualToString:signalQualityAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
//        if (!self.isOpenReal) {
//            [MBProgressUtils showMsg:@"请先打开实时数据监听" view:self.view];
//            return;
//        }
        [[FlexPasterSDK sharedInstance] realDataListener:self];
        
        ///数据质量检测
        BOOL signalQuality = [[FlexPasterSDK sharedInstance] signalQualityWithData];
        [MBProgressUtils showMsg:signalQuality ? @"数据质量好" : @"数据质量差" view:self.view];
        
    }
    else  if ([action isEqualToString:deviceInfoAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        
        DeviceTypeModel *model = [[FlexPasterSDK sharedInstance] deviceInfo];
        if (model) {
            [MBProgressUtils showMsg:@"已获取设备信息，请查看回调函数" view:self.view];
        }
        
    }
    else  if ([action isEqualToString:onlineStageAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
        [[FlexPasterSDK sharedInstance] onlineStage:self];
        
    }
    else if ([action isEqualToString:lookWaveAction]) {
        
        if (![self isConnected]) {
            return;
        }
        
//        if (!self.isOpenReal) {
//            [MBProgressUtils showMsg:@"请先打开实时数据监听" view:self.view];
//            return;
//        }
        [[FlexPasterSDK sharedInstance] realDataListener:self];
        
        LookWaveVC *vc = [[LookWaveVC alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if ([action isEqualToString:realIndexAction]) {
        if (![self isConnected]) {
            return;
        }
        
        [self.navigationController pushViewController:[[RealIndexVC alloc] init] animated:YES];
    } else if ([action isEqualToString:startMeditation]) {
        if (![self isConnected]) {
            return;
        }
        
        [[FlexPasterSDK sharedInstance] startMeditationWith:self];
        
        LookWaveVC *vc = [[LookWaveVC alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([action isEqualToString:closeMeditation]) {
        
        [[FlexPasterSDK sharedInstance] stopMeditation];
    } else if ([action isEqualToString:queryOfflineDataAction]) {
        if (!self.savedEdfName || !self.savedUID || !self.savedUser) {
            [MBProgressUtils showMsg:@"本地未保存edf、uid、user 数据" view:self.view];
            return;
        }
        [[FlexPasterSDK sharedInstance] queryOfflineDataWithEdf:self.savedEdfName user:self.savedUser uid:self.savedUID offlineDataDelegate:self];
    } else if ([action isEqualToString:mergeOfflineDataAction]) {
        
        if (self.hasOfflineData) {
            [[FlexPasterSDK sharedInstance] mergeOfflineData];
        } else {
            [MBProgressUtils showMsg:@"请先查询有无离线数据" view:self.view];
        }
    } else if ([action isEqualToString:cancelOfflineDataAction]) {
        if (!self.hasOfflineData) {
            [MBProgressUtils showMsg:@"请先查询有无离线数据" view:self.view];
        } else {
            [MBProgressUtils showMsg:@"正在取消离线数据合并" view:self.view];
            [[FlexPasterSDK sharedInstance] cancelMergeOfflineData];
        }
    } 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"柔灵 iOS SDK";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 90)];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 180, self.view.frame.size.width, self.view.frame.size.height - 190)];
    tableView.rowHeight = 50;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    UILabel *lab = [[UILabel alloc] init];
    lab.frame = CGRectMake(0, 80, 300, 40);
    lab.textColor = [UIColor blackColor];
    lab.font = [UIFont systemFontOfSize:15];
    lab.numberOfLines = 2;
    self.tempLabel = lab;
    [self.view addSubview:lab];
    
    [[FlexPasterSDK sharedInstance] authorityWithAppKey:AppKey appSecret:AppSecret block:^(BOOL isSuccess, NSArray * _Nonnull apiList) {
        //返回已经授权的接口列表，具体的接口对应的名称，可以参考 FlexPasterSDK.h
        for (NSString *api in apiList) {
            
            for (ApiModel *model in self.items) {
                
                if (equal(api, model.action)) {
                    model.isAuthority = YES;
                    break;
                }
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
        
    }];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.savedUser = [userDefault valueForKey:@"savedUser"];
    self.savedUID = [userDefault valueForKey:@"savedUID"];
    self.savedEdfName = [userDefault valueForKey:@"savedEdfName"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(temp:) name:@"temp_noti" object:nil];
    
    ///播放音乐，加强保活
//    self.audioHelper = [[AudioHelper alloc] init];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"银河" ofType:@"mp3"];
//    [self.audioHelper playerWithFilePath:filePath];
}

- (void) temp:(NSNotification *) noti {
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss SSS";
    NSString *timeStr = [formatter stringFromDate:[NSDate now]];
    self.disConnectedCnt ++;
    NSLog(@"断开时间：%@，断开次数：%ld", timeStr, self.disConnectedCnt);
    self.tempLabel.text = [NSString stringWithFormat:@"断开时间：%@，断开次数：%ld", timeStr, self.disConnectedCnt];
    
}

- (BOOL) isConnected {
    if (![FlexPasterSDK sharedInstance].isConnected) {
        [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
        return NO;
    }
    
    return YES;
}

- (NSMutableArray<NSNumber *> *) tempDataArray {
    if (!_tempDataArray) {
        _tempDataArray = [NSMutableArray array];
    }
    return _tempDataArray;
}

#pragma mark ScanPasterDelegate
- (void) onScanResult:(BLEModel *)bleModel {
    NSLog(@"扫描到设备%@", bleModel.deviceName);
}
#pragma mark PasterConnectDelegate
- (void) onConnectResult:(ConnectResultType)connectResultType {
//    NSLog(@"连接成功")
}
#pragma mark RealTimeDataDelegate
- (void) onRealTimeData:(NSMutableArray<NSNumber *> *)eegData {
//    NSLog(@"onRealTimeFilterData 接收到原始数据");
    [self.tempDataArray addObjectsFromArray:eegData];
    if (self.tempDataArray.count > 10 * 250) {
        [self.tempDataArray removeObjectsInRange:NSMakeRange(0, self.tempDataArray.count - 10 * 250)];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RealIndexVC" object:eegData];
}
- (void) onRealTimeFilterData:(NSMutableArray<NSNumber *> *)eegData {
//    NSLog(@"onRealTimeFilterData 接收到滤波数据");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"eeg_filter_data" object:eegData];
    
}
- (void) onOpenRealTime:(BOOL)isOpenSuccess {
    self.isOpenReal = YES;
    [MBProgressUtils showMsg:@"打开数据实时监听" view:self.view];
}

#pragma mark PickDataDelegate
- (void) onPickUpData:(NSMutableArray<NSNumber *> *)eegData second:(NSUInteger)second {
    [MBProgressUtils showMsg:@"接收数据成功，请看回调函数或控制台" view:self.view];
}

#pragma mark RecordDelegate
- (void) onStopRecord {
    [MBProgressUtils showMsg:[NSString stringWithFormat:@"结束记录，文件名%@", self.savedEdfName] view:self.view];
}
- (void) onStartRecordWithPath:(NSString *)edfPath {
    [MBProgressUtils showMsg:@"开始记录..." view:self.view];//202402591910_60b93a08_ABCDE.edf
    NSLog(@"edf=%@", edfPath);
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:edfPath forKey:@"savedEdfName"];
}
///eegArray 脑电
///accelArray 加速度
///gyroArray 角速度
- (void) onRecordingEEG:(NSMutableArray<NSNumber *> *)eegArray accel:(NSMutableArray<NSNumber *> *)accelArray gyro:(NSMutableArray<NSNumber *> *)gyroArray {
    NSDateFormatter *formatter = [NSDateFormatter new];
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss SSS";
    NSString *timeStr = [formatter stringFromDate:[NSDate now]];
    
    NSLog(@"数据采集：进行中-时间：%@", timeStr);
}
- (void) onRecordFailure:(RecordEventError)recordError {
    NSLog(@"数据采集：错误-原因：%ld", recordError);
}
- (void) onRecordEventResult:(NSInteger)eventResult {
    [MBProgressUtils showMsg:@"已添加事件" view:self.view];
}

- (void) onReturnUID:(NSString *)uid user:(nonnull NSString *)user edfName:(nonnull NSString *)edfName{
    self.savedUID = uid;
    self.savedUser = user;
    self.savedEdfName = edfName;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:uid forKey:@"savedUID"];
    [userDefault setValue:user forKey:@"savedUser"];
    [userDefault setValue:edfName forKey:@"savedEdfName"];
    [MBProgressUtils showMsg:@"开始记录" view:self.view];
}

#pragma mark OnlineStageDelegate
- (void) onlineStage:(NSUInteger)stage {
    NSLog(@"分期结果：%ld", stage);
    ///0 深睡 1 浅睡 2 REM 3 清醒
}

#pragma mark MeditationDelegate
- (void) onMeditationScore:(CGFloat)score {
    NSLog(@"===score=%.f", score);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"meditation_score" object:@(score)];
}

#pragma mark OfflineDataDelegate
- (void) queryOfflineResultWithUid:(NSString *)uid {
    ///uid 不为空代表存在离线数据
    NSLog(@"uid=%@", uid);
    self.hasOfflineData = [uid isEqualToString:self.savedUID];
    [MBProgressUtils showMsg:self.hasOfflineData ? @"有离线数据" : @"无离线数据" view:self.view];
}
///progress 合并进度
///code :1000 正常 1001 失败 1002 取消 1003 设备断连
- (void) mergeOfflineDataWithEdf:(NSString *)edfName progress:(float)progress step:(NSInteger)code {
    NSLog(@"合并进度%f", progress);
    if (progress == 100) {
        self.hasOfflineData = NO;///合并完成，把标志位置为 NO
    }
    
    if (code == 1003) {///设备断连，开发者可以在 UI 上提醒用户设备断连，需要重新连接设备后再次点击同步
        NSLog(@"同步中设备断连");
    }
}
@end

@implementation ApiModel

- (instancetype) initWithShowTitle:(NSString *) showTitle action:(NSString *) action{
    if (self = [super init]) {
        _showTitle = showTitle;
        _action = action;
    }
    return self;
}

@end
