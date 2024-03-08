//
//  LookWaveVC.m
//  PasterSDKDemoDemo
//
//  Created by frank on 2023/3/10.
//

#import "LookWaveVC.h"
#import "FlexPasterSDK.h"

//一屏显示最大数量
#define PointNumber  (1000)

@interface LookWaveVC ()
@property(nonatomic, strong) CAShapeLayer* eegShapeLayer;

@property (nonatomic, strong) UIBezierPath *eegBezierPath;

@property(nonatomic, assign) CGFloat maxWidth;

@property(nonatomic, assign) CGFloat maxHeight;

@property(nonatomic, strong) UIView* contentView;
///脑电滤波后的值
@property(nonatomic, strong) NSMutableArray<NSNumber *>* filterArray;
///冥想数值
@property(nonatomic, strong) NSMutableArray<NSNumber *>* meditationArray;

@end


@implementation LookWaveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.maxWidth = self.view.frame.size.width;
    
    self.maxHeight = 200;
    
    [self setupContentView];
    ///脑电波形
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawWave:) name:@"eeg_filter_data" object:nil];
    ///冥想数值
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawMeditation:) name:@"meditation_score" object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    ///如果开启了冥想分数，需要关闭
    [[FlexPasterSDK sharedInstance] stopMeditation];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIView *) contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor blackColor];
        _contentView.layer.cornerRadius = 10;
    }
    return _contentView;
}
-(CAShapeLayer *)eegShapeLayer{
    if (_eegShapeLayer == nil) {
        _eegShapeLayer = [CAShapeLayer layer];
        _eegShapeLayer.lineWidth = 1;
        _eegShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        _eegShapeLayer.frame = CGRectMake(0.0, 0.0, self.maxWidth, self.maxHeight);
        _eegShapeLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _eegShapeLayer;
}

-(UIBezierPath *)eegBezierPath{
    if (_eegBezierPath == nil) {
        _eegBezierPath = [UIBezierPath bezierPath];
        _eegBezierPath.lineWidth = 1;
        _eegBezierPath.lineCapStyle = kCGLineCapRound;   // 线条拐角
        _eegBezierPath.lineJoinStyle = kCGLineJoinRound; // 终点处理
    }
    return _eegBezierPath;
}

- (NSMutableArray<NSNumber *> *) filterArray {
    if (!_filterArray) {
        _filterArray = [NSMutableArray array];
    }
    return _filterArray;
}
- (NSMutableArray<NSNumber *> *) meditationArray {
    if (!_meditationArray) {
        _meditationArray = [NSMutableArray array];
    }
    return _meditationArray;
}

- (void) setupContentView {
    
    self.contentView.frame = CGRectMake(0, 0, self.maxWidth-40, self.maxHeight);
    self.contentView.center = self.view.center;
    [self.view addSubview:self.contentView];
    
}


// 绘制曲线操作
-(void)updateWave:(NSMutableArray<NSNumber *> *) dataArray{
    
    if (dataArray.count == 0) {
        return;
    }
    
    if (self.eegBezierPath) {
        [self.eegBezierPath removeAllPoints];
    }

    NSInteger startIndex = 0;
    
    if (dataArray.count > PointNumber) {
        startIndex = dataArray.count - PointNumber;
    }

    CGFloat unitWidth = self.maxWidth / PointNumber;
    
    CGPoint lastPoint = CGPointZero;
    
    for (NSInteger i = startIndex; i < dataArray.count; i ++) {
        
        CGFloat yValue = dataArray[i].floatValue;
        
        CGFloat xValue = unitWidth * (i - startIndex);
        
        CGPoint pointValue = CGPointMake(xValue, yValue);
        
//        NSLog(@"-----x=%.f, y = %.f", xValue, yValue);
        
        if (i == startIndex) {
            
            [self.eegBezierPath moveToPoint:pointValue];
            
        } else {
            
            CGPoint midPoint = CGPointMake((pointValue.x + lastPoint.x) / 2.0, (pointValue.y + lastPoint.y) / 2.0);
            [self.eegBezierPath addQuadCurveToPoint:midPoint controlPoint:lastPoint];
            
        }
        
        lastPoint = pointValue;
        
    }
    self.eegShapeLayer.path = self.eegBezierPath.CGPath;
    [self.contentView.layer addSublayer:self.eegShapeLayer];

}

#pragma mark 绘制脑电波形图
- (void) drawWave:(NSNotification *) noti {
    if (![noti.object isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    
    NSMutableArray<NSNumber *> *orignArray = noti.object;
    //计算 y 值
    for (NSNumber *number in orignArray) {
        CGFloat value = [self calculateYValue:number];
        [self.filterArray addObject:@(value)];
    }
    
    [self updateWave:self.filterArray];
    
}
#pragma mark 绘制冥想数值
- (void) drawMeditation:(NSNotification *) noti {

    NSNumber *number = noti.object;
    CGFloat score = number.floatValue;
    //计算 y 值
    CGFloat showY = [self calculateMediYValue:score];
    [self.meditationArray addObject:@(showY)];
    
    dispatch_async(dispatch_get_main_queue(), ^{    
        [self updateWave:self.meditationArray];
    });
    
}

-(CGFloat)calculateYValue:(NSNumber *) eegValue {
    if (!eegValue) {
        return self.maxHeight / 2;
    }
    
    CGFloat eeg = eegValue.floatValue;
    
    if (eeg == 0) {
        return self.maxHeight / 2;
    }
    
    ///滤波之后的值基本在 -20 到 20 之间
    eeg = eeg > 20 ? 20 : eeg;
    eeg = eeg < -20 ? -20 : eeg;
    
    return self.maxHeight / 2 + eeg / 40.0 * self.maxHeight / 2;
    
}

-(CGFloat)calculateMediYValue:(CGFloat) score {
    
    return score / 100 * self.maxHeight;
    
}
@end
