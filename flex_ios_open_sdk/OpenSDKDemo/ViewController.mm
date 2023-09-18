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
#define filterParamAction    @"setFilterParam"              ///滤波参数
#define startRecordAction    @"startRecord"                 ///开始记录
#define stopRecordAction    @"stopRecord"                   ///停止记录
#define addEventAction    @"addEvent"                       ///添加事件
#define signalQualityAction    @"signalQuality"             ///信号质量
#define deviceInfoAction    @"deviceInfo"                   ///设备信息
#define onlineStageAction    @"setSleepStageListener"       ///分期状态
#define lookWaveAction    @"lookWaveAction"                 ///查看波形
#define realIndexAction    @"sleepRealIndex"                ///实时指标


#define AppKey @"rla3a8ddefdfca"
#define AppSecret @"a3a8ddefdfca1949631353017dd1b038"

#define equal(str1, str2) [str1 isEqualToString:str2]

static NSString *cellId = @"cellId";

@interface ViewController ()<ScanPasterDelegate, PasterConnectDelegate, RealTimeDataDelegate, PickDataDelegate, RecordDelegate, OnlineStageDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray<NSNumber *>* tempDataArray;
@property(nonatomic, strong) NSMutableArray<ApiModel *>* items;
@property(nonatomic, assign) BOOL isOpenSuccess;

@property(nonatomic, copy) NSString* binPath;
@property(nonatomic, copy) NSString* paramPath;

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
            [[ApiModel alloc] initWithShowTitle:@"滤波参数" action:filterParamAction],
            [[ApiModel alloc] initWithShowTitle:@"开始记录" action:startRecordAction],
            [[ApiModel alloc] initWithShowTitle:@"停止记录" action:stopRecordAction],
            [[ApiModel alloc] initWithShowTitle:@"添加事件" action:addEventAction],
            [[ApiModel alloc] initWithShowTitle:@"信号质量" action:signalQualityAction],
//            [[Model alloc] initWithShowTitle:@"设备信息" action:deviceInfoAction],
            [[ApiModel alloc] initWithShowTitle:@"分期状态" action:onlineStageAction],
            [[ApiModel alloc] initWithShowTitle:@"查看波形" action:lookWaveAction],
            [[ApiModel alloc] initWithShowTitle:@"实时指标" action:realIndexAction],
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
    if ([self.items[indexPath.row].showTitle isEqualToString:@"实时指标"]) {
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
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        if (!self.isOpenSuccess) {
            [MBProgressUtils showMsg:@"请先打开数据实时监听" view:self.view];
            return;
        }
        
        
        [[FlexPasterSDK sharedInstance] pickupDataListener:self second:5];
        
    }
    else  if ([action isEqualToString:rssiAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        
        NSInteger rssi = [[FlexPasterSDK sharedInstance] deviceRSSI];
        [MBProgressUtils showMsg:[NSString stringWithFormat:@"信号强度为%ld dBm", rssi] view:self.view];
    }
    else  if ([action isEqualToString:batteryAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        
        NSUInteger battery = [[FlexPasterSDK sharedInstance] battery];
        [MBProgressUtils showMsg:[NSString stringWithFormat:@"设备电量为%ld %%", battery] view:self.view];
        
    }
    else  if ([action isEqualToString:isWearAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        if (!self.isOpenSuccess) {
            [MBProgressUtils showMsg:@"请先打开数据实时监听" view:self.view];
            return;
        }
        
        BOOL isWear = [[FlexPasterSDK sharedInstance] isWearPatch];
        [MBProgressUtils showMsg:isWear ? @"设备已穿戴" : @"设备未穿戴" view:self.view];
        
    }
    else  if ([action isEqualToString:filterParamAction]) {
        
        [[FlexPasterSDK sharedInstance] filterParam:4 hp:50 lp:5];
        [MBProgressUtils showMsg:[NSString stringWithFormat:@"已设置为order=4,hp=50,lp=5"] view:self.view];
        
    }
    else  if ([action isEqualToString:startRecordAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        if (!self.isOpenSuccess) {
            [MBProgressUtils showMsg:@"请先打开数据实时监听" view:self.view];
            return;
        }
        
        UserInfoModel *model = [[UserInfoModel alloc] init];
        model.birthday = @"2023-02-03";
        model.sex = @"m";
        model.name = @"海啸";
        model.deviceName = @"Flex-BM05-500020";
    
        NSString *edfName = [NSString stringWithFormat:@"%ld", [[NSDate now] timeIntervalSince1970]];
    
        [[FlexPasterSDK sharedInstance] startRecordWithEdfName:edfName userInfo:model recordDelegate:self];
        
    }
    else  if ([action isEqualToString:stopRecordAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        if (!self.isOpenSuccess) {
            [MBProgressUtils showMsg:@"请先打开数据实时监听" view:self.view];
            return;
        }
        
        [[FlexPasterSDK sharedInstance] stopRecord];
        
    }
    else  if ([action isEqualToString:addEventAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        if (!self.isOpenSuccess) {
            [MBProgressUtils showMsg:@"请先打开数据实时监听" view:self.view];
            return;
        }
        
        long long startTimeStamp = [[NSDate date] timeIntervalSince1970]*1000*10;
        long long duration = 1000*10;

        [[FlexPasterSDK sharedInstance] addEdfEventWithStartTime:startTimeStamp duration:duration eventContent:@"test event"];
        
    }
    else  if ([action isEqualToString:signalQualityAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        if (!self.isOpenSuccess) {
            [MBProgressUtils showMsg:@"请先打开数据实时监听" view:self.view];
            return;
        }
        if (!self.tempDataArray || self.tempDataArray.count == 0) {
            [MBProgressUtils showMsg:@"请先截取一段数据" view:self.view];
            return;
        }
        
        BOOL signalQuality = [[FlexPasterSDK sharedInstance] signalQualityWithData:self.tempDataArray dataLen:self.tempDataArray.count];
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
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        if (!self.isOpenSuccess) {
            [MBProgressUtils showMsg:@"请先打开数据实时监听" view:self.view];
            return;
        }
        
        [[FlexPasterSDK sharedInstance] onlineStage:self binPath:self.binPath paramPath:self.paramPath];
        [MBProgressUtils showMsg:@"开启分期状态，请稍等30s左右" view:self.view];
        
    }
    else if ([action isEqualToString:lookWaveAction]) {
        
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        if (!self.isOpenSuccess) {
            [MBProgressUtils showMsg:@"请先打开数据实时监听" view:self.view];
            return;
        }
        
        LookWaveVC *vc = [[LookWaveVC alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if ([action isEqualToString:realIndexAction]) {
        if (![FlexPasterSDK sharedInstance].isConnected) {
            [MBProgressUtils showMsg:@"请先连接设备" view:self.view];
            return;
        }
        if (!self.isOpenSuccess) {
            [MBProgressUtils showMsg:@"请先打开数据实时监听" view:self.view];
            return;
        }
        
        [self.navigationController pushViewController:[[RealIndexVC alloc] init] animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"柔灵 iOS SDK";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 90)];
    tableView.rowHeight = 50;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    ///配置模型路径
    self.binPath = [[NSBundle mainBundle] pathForResource:@"sleep_m_0310" ofType:@"b"];
    self.paramPath = [[NSBundle mainBundle] pathForResource:@"sleep_m_0310" ofType:@"p"];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RealIndexVC" object:eegData];
}
- (void) onRealTimeFilterData:(NSMutableArray<NSNumber *> *)eegData {
//    NSLog(@"onRealTimeFilterData 接收到滤波数据")
    [[NSNotificationCenter defaultCenter] postNotificationName:@"eeg_filter_data" object:eegData];
    
}
- (void) onOpenRealTime:(BOOL)isOpenSuccess {
    self.isOpenSuccess = isOpenSuccess;
    [MBProgressUtils showMsg:@"打开数据实时监听" view:self.view];
}

#pragma mark PickDataDelegate
- (void) onPickUpData:(NSMutableArray<NSNumber *> *)eegData second:(NSUInteger)second {
    self.tempDataArray = eegData;
    [MBProgressUtils showMsg:@"接收数据成功，请看回调函数或控制台" view:self.view];
}

#pragma mark RecordDelegate
- (void) onStopRecord {
    [MBProgressUtils showMsg:@"结束记录...，edf存放在cache目录" view:self.view];
}
- (void) onStartRecordWithPath:(NSString *)edfPath {
    [MBProgressUtils showMsg:@"开始记录..." view:self.view];
}
- (void) onRecording {
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

#pragma mark OnlineStageDelegate
- (void) onlineStage:(NSUInteger)stage {
    NSLog(@"分期结果：%ld", stage);
    ///0 深睡 1 浅睡 2 REM 3 清醒
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
