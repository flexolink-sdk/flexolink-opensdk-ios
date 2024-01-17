//
//  RealIndexVC.m
//  OpenSDKDemoDemo
//
//  Created by frank on 2023/9/18.
//

#import "RealIndexVC.h"
#import "FlexPasterSDK.h"
#import "PasterListener.h"

@interface RealIndexVC ()<RealIndexDelegate>
///神经放松度 Nerve relaxation
@property(nonatomic, strong) UILabel* nerveRelaxationLabel;
///思维活跃度 Mental activity
@property(nonatomic, strong) UILabel* mentalActivityLabel;
///神经疲劳度 Neurofatigue
@property(nonatomic, strong) UILabel* neurofatigueLabel;

@property(nonatomic, strong) NSMutableArray<NSNumber *>* dataArray;
@end

@implementation RealIndexVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    
    [[FlexPasterSDK sharedInstance] setRealListener:self deviceType:@"Flex-BM05"];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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
    
    self.nerveRelaxationLabel = [self reusedLabel];
    self.mentalActivityLabel = [self reusedLabel];
    self.neurofatigueLabel = [self reusedLabel];
    
    [self.view addSubview:self.nerveRelaxationLabel];
    [self.view addSubview:self.mentalActivityLabel];
    [self.view addSubview:self.neurofatigueLabel];
    
    self.nerveRelaxationLabel.frame = CGRectMake(20, 100, 200, 50);
    self.mentalActivityLabel.frame = CGRectMake(20, 150, 200, 50);
    self.neurofatigueLabel.frame = CGRectMake(20, 200, 200, 50);
    
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

- (NSMutableArray<NSNumber *> *) dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void) realIndexListener:(NSArray<NSNumber *> *)indexArray {
    self.nerveRelaxationLabel.text = [NSString stringWithFormat:@"神经放松度 %ld", indexArray[0].integerValue];
    self.mentalActivityLabel.text = [NSString stringWithFormat:@"思维活跃度 %ld", indexArray[1].integerValue];
    self.neurofatigueLabel.text = [NSString stringWithFormat:@"神经疲劳度 %ld", indexArray[2].integerValue];
}

@end
