//
//  DeviceListViewController.m
//  FlexPasterSDK
//
//  Created by frank on 2023/2/3.
//

#import "DeviceListViewController.h"
#import "MBProgressUtils.h"
#import "DeviceTableCell.h"
#import "FlexPasterSDK.h"

static NSString *cellId = @"cellId";

@interface DeviceListViewController ()<UITableViewDelegate, UITableViewDataSource, ScanPasterDelegate, DeviceTableCellDelagate, PasterConnectDelegate>

@property(nonatomic, strong) UITableView *tableview;

@property(nonatomic, strong) UIButton* startScanBtn;

@property(nonatomic, strong) UIButton* stopScanBtn;

@property(nonatomic, strong) NSMutableArray<BLEModel *>* dataArray;

@end

@implementation DeviceListViewController

@synthesize dataArray = _dataArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height-120)];
    _tableview.rowHeight = 50;
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [_tableview registerClass:[DeviceTableCell class] forCellReuseIdentifier:cellId];
    
    [self.view addSubview:_tableview];
    
    _startScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startScanBtn setTitle:@"扫描" forState:UIControlStateNormal];
    [_startScanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _startScanBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_startScanBtn addTarget:self action:@selector(scanBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _startScanBtn.layer.borderWidth = 0.5;
    _startScanBtn.layer.borderColor = [UIColor blackColor].CGColor;
    _startScanBtn.frame = CGRectMake(10, 85, 80, 30);
    
    _stopScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_stopScanBtn setTitle:@"停止扫描" forState:UIControlStateNormal];
    [_stopScanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _stopScanBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_stopScanBtn addTarget:self action:@selector(stopScanBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _stopScanBtn.layer.borderWidth = 0.5;
    _stopScanBtn.layer.borderColor = [UIColor blackColor].CGColor;
    _stopScanBtn.frame = CGRectMake(self.view.frame.size.width-90, 85, 80, 30);
    
    [self.view addSubview:_startScanBtn];
    [self.view addSubview:_stopScanBtn];
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[FlexPasterSDK sharedInstance] stopScan];
    [MBProgressUtils showMsg:@"停止扫描" view:self.view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITableViewDelegate,UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    [cell setIndex:indexPath.row];
    
    BLEModel *model = self.dataArray[indexPath.row];
    
    [cell setModel:model];
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark 懒加载
- (NSMutableArray<BLEModel *> *) dataArray {
    if (!_dataArray) {
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

#pragma mark 事件
- (void) scanBtnAction:(UIButton *) sender {
    [[FlexPasterSDK sharedInstance] startScan:self];
    [MBProgressUtils showMsg:@"扫描中..." view:self.view];
}
- (void) stopScanBtnAction:(UIButton *) sender {
    [[FlexPasterSDK sharedInstance] stopScan];
    [MBProgressUtils showMsg:@"停止扫描" view:self.view];
}

#pragma mark ScanPasterDelegate
- (void) onScanResult:(BLEModel *)bleModel {
    
    [self.dataArray addObject:bleModel];
    
    [self.tableview reloadData];
}

#pragma mark PasterConnectDelegate
- (void) onConnectResult:(ConnectResultType)connectResultType {
    [self.tableview reloadData];
    if (connectResultType == ConnectResultSuccess) {
        [MBProgressUtils showMsg:@"连接成功" view:self.view];
    } else if (connectResultType == ConnectResultFaild) {
        [MBProgressUtils showMsg:@"断开连接" view:self.view];
    }
}

#pragma mark DeviceTableCellDelagate
- (void) deviceTableCell:(DeviceTableCell *)cell btnIndex:(NSInteger)index isConnected:(BOOL)isConnected {
    
    if (isConnected) {
        ///关闭连接
        [[FlexPasterSDK sharedInstance] closeBleDevice];
        [MBProgressUtils showMsg:@"关闭连接" view:self.view];
        
    } else {
        ///连接
        ///连接前需要确保没有连接其他设备，因此先断开设备连接再连接新设备
        [[FlexPasterSDK sharedInstance] closeBleDevice];
        BLEModel *model = self.dataArray[index];
        [[FlexPasterSDK sharedInstance] connectBleDevice:self connectPeripheral:model];
        [MBProgressUtils showMsg:@"连接设备中..." view:self.view];
    }
}
@end
