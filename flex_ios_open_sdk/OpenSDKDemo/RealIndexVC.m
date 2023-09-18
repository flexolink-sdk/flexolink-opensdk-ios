//
//  RealIndexVC.m
//  OpenSDKDemoDemo
//
//  Created by frank on 2023/9/18.
//

#import "RealIndexVC.h"
#import "SleepRealIndex.h"

@interface RealIndexVC ()
///神经放松度 Nerve relaxation
@property(nonatomic, strong) UILabel* nerveRelaxationLabel;
///思维活跃度 Mental activity
@property(nonatomic, strong) UILabel* mentalActivityLabel;
///神经疲劳度 Neurofatigue
@property(nonatomic, strong) UILabel* neurofatigueLabel;
///实时数据质量检测结果
@property(nonatomic, strong) UILabel* signalResultLabel;

@property(nonatomic, strong) NSMutableArray<NSNumber *>* dataArray;
@end

@implementation RealIndexVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    
    ///接收脑电实时数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(realData:) name:@"RealIndexVC" object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) setupUI {
    self.signalResultLabel = [self reusedLabel];
    self.nerveRelaxationLabel = [self reusedLabel];
    self.mentalActivityLabel = [self reusedLabel];
    self.neurofatigueLabel = [self reusedLabel];
    
    [self.view addSubview:self.nerveRelaxationLabel];
    [self.view addSubview:self.mentalActivityLabel];
    [self.view addSubview:self.neurofatigueLabel];
    [self.view addSubview:self.signalResultLabel];
    
    self.signalResultLabel.frame = CGRectMake(20, 100, 300, 40);
    self.nerveRelaxationLabel.frame = CGRectMake(20, 300, 200, 40);
    self.mentalActivityLabel.frame = CGRectMake(20, 400, 200, 40);
    self.neurofatigueLabel.frame = CGRectMake(20, 500, 200, 40);
    
//    self.signalResultLabel.text = @"实时数据质量检测结果";
    self.nerveRelaxationLabel.text = @"神经放松度";
    self.mentalActivityLabel.text = @"思维活跃度";
    self.neurofatigueLabel.text = @"神经疲劳度";
}

- (UILabel *) reusedLabel {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:20];
    return label;
}

- (void) realData:(NSNotification *) noti {
    NSMutableArray<NSNumber *> *realArray = noti.object;
    
    [self.dataArray addObjectsFromArray:realArray];
    
    if (self.dataArray.count >= 2500) {
        NSDictionary *dic = [SleepRealIndex signalQualityWith:self.dataArray deviceType:@"Flex-BM05"];
        NSNumber *signal = [dic objectForKey:@"signal"];//实时信号检测是否通过
        if (signal.boolValue) {
            NSMutableArray<NSNumber *> *realResultArray = [dic objectForKey:@"data"];///实时信号检测结果
            ///0神经放松度，1思维活跃度，2神经疲劳度
            self.nerveRelaxationLabel.text = [NSString stringWithFormat:@"神经放松度 %ld", realResultArray[0].integerValue];
            self.mentalActivityLabel.text = [NSString stringWithFormat:@"思维活跃度 %ld", realResultArray[1].integerValue];
            self.neurofatigueLabel.text = [NSString stringWithFormat:@"神经疲劳度 %ld", realResultArray[2].integerValue];
//            self.signalResultLabel.text = @"实时数据质量检测结果：通过";
        } else {
//            self.signalResultLabel.text = @"实时数据质量检测结果：未通过";
        }
        ///每秒钟调用1次，因此减去 250 条数据，开发者可自行定义调用的频率，也可以使用定时器定时调用 [SleepRealIndex signalQualityWith deviceType]函数
        [self.dataArray removeObjectsInRange:NSMakeRange(0, 250)];
    }
}

- (NSMutableArray<NSNumber *> *) dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
