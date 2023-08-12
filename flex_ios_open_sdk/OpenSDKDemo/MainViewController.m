//
//  ViewController.m
//  PasterSDK
//
//  Created by frank on 2023/1/30.
//

#import "MainViewController.h"
#import "ViewController.h"
#import "DeviceListViewController.h"
#import "MBProgressUtils.h"
#import "PWMD5Utilities.h"
#import "FlexPasterSDK.h"
#import "LookWaveVC.h"

#define scanAction    @"scanBleDevice"                     ///扫描
#define stopScanAction    @"stopScan"             ///停止扫描
#define connectAction    @"connect"               ///连接
#define statusAction    @"isConnected"                 ///连接状态
#define closeConnectAction    @"closeDevice"     ///关闭连接
#define receiveAction    @"setRealDataListener"               ///接收数据
#define subDataAction    @"pickDataByPointStamp"               ///截取数据
#define rssiAction    @"getDeviceRssi"                     ///信号强度
#define batteryAction    @"getBattery"               ///设备电量
#define isWearAction    @"isWearPatch"                 ///是否穿戴
#define filterParamAction    @"setFilterParam"       ///滤波参数
#define startRecordAction    @"startRecord"       ///开始记录
#define stopRecordAction    @"stopRecord"         ///停止记录
#define addEventAction    @"addEvent"             ///添加事件
#define signalQualityAction    @"SignalQuality"   ///信号质量
#define deviceInfoAction    @"deviceInfo"         ///设备信息
#define onlineStageAction    @"setSleepStageListener"       ///分期状态
#define lookWaveAction    @"lookWaveAction"       ///查看波形

#define equal(str1, str2) [str1 isEqualToString:str2]

static NSString *cellId = @"cellId";

@interface MainViewController ()<ScanPasterDelegate, PasterConnectDelegate, RealTimeDataDelegate, PickDataDelegate, RecordDelegate, OnlineStageDelegate, UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) BLEModel* tempModel;
@property(nonatomic, strong) NSMutableArray<NSNumber *>* tempDataArray;
@property(nonatomic, strong) NSMutableArray<Model *>* items;
@property(nonatomic, assign) BOOL isOpenSuccess;

@end

@implementation MainViewController

- (NSMutableArray<Model *> *) items {
    if (!_items) {
        _items = [NSMutableArray arrayWithArray:@[
            [[Model alloc] initWithShowTitle:@"扫描" action:scanAction],
            [[Model alloc] initWithShowTitle:@"停止扫描" action:stopScanAction],
            [[Model alloc] initWithShowTitle:@"连接状态" action:statusAction],
            [[Model alloc] initWithShowTitle:@"关闭连接" action:closeConnectAction],
            [[Model alloc] initWithShowTitle:@"数据实时监听" action:receiveAction],
            [[Model alloc] initWithShowTitle:@"截取数据（5s）" action:subDataAction],
            [[Model alloc] initWithShowTitle:@"信号强度" action:rssiAction],
            [[Model alloc] initWithShowTitle:@"设备电量" action:batteryAction],
            [[Model alloc] initWithShowTitle:@"是否穿戴" action:isWearAction],
            [[Model alloc] initWithShowTitle:@"滤波参数" action:filterParamAction],
            [[Model alloc] initWithShowTitle:@"开始记录" action:startRecordAction],
            [[Model alloc] initWithShowTitle:@"停止记录" action:stopRecordAction],
            [[Model alloc] initWithShowTitle:@"添加事件" action:addEventAction],
            [[Model alloc] initWithShowTitle:@"信号质量" action:signalQualityAction],
//            [[Model alloc] initWithShowTitle:@"设备信息" action:deviceInfoAction],
            [[Model alloc] initWithShowTitle:@"分期状态" action:onlineStageAction],
            [[Model alloc] initWithShowTitle:@"查看波形" action:lookWaveAction],
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
    
    if (indexPath.row == self.items.count - 1) {
        cell.detailTextLabel.hidden = YES;
    } else {
        cell.detailTextLabel.hidden = NO;
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
        
        [[FlexPasterSDK sharedInstance] onlineStage:self];
//        [MBProgressUtils showMsg:@"开启分期状态，30s后请查看回调函数" view:self.view];
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
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"SDK";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 90)];
    tableView.rowHeight = 50;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    [[FlexPasterSDK sharedInstance] authorityWithAppKey:@"rla3a8ddefdfca" appSecret:@"a3a8ddefdfca1949631353017dd1b038" block:^(BOOL isSuccess, NSArray * _Nonnull apiList) {
        //返回已经授权的接口列表，具体的接口对应的名称，可以参考 FlexPasterSDK.h
        for (NSString *api in apiList) {
            
            for (Model *model in self.items) {
                
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

- (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;

    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
}

#pragma mark ScanPasterDelegate
- (void) onScanResult:(BLEModel *)bleModel {
//    NSLog(@"扫描通过")
    //AirDream1-84A8
    if ([bleModel.deviceName isEqualToString:@"Flex-BM05-500020"]) {
        self.tempModel = bleModel;
    }
}
#pragma mark PasterConnectDelegate
- (void) onConnectResult:(ConnectResultType)connectResultType {
//    NSLog(@"连接成功")
}
#pragma mark RealTimeDataDelegate
- (void) onRealTimeData:(NSMutableArray<NSNumber *> *)eegData {
//    NSLog(@"onRealTimeFilterData 接收到原始数据")
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
//    NSString *stageName = nil;
//    switch (stage) {
//        case 0:
//            stageName = @"深睡";
//            break;
//        case 1:
//            stageName = @"浅睡";
//            break;
//        case 2:
//            stageName = @"REM";
//            break;
//        case 3:
//            stageName = @"清醒";
//            break;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [MBProgressUtils showMsg:stageName view:self.view];
//    });
}
@end

@implementation Model

- (instancetype) initWithShowTitle:(NSString *) showTitle action:(NSString *) action{
    if (self = [super init]) {
        _showTitle = showTitle;
        _action = action;
    }
    return self;
}

@end
