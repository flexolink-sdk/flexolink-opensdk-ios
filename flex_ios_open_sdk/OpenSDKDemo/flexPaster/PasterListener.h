//
//  PasterAction.h
//  PasterSDK
//
//  Created by frank on 2023/1/30.
//

#import <Foundation/Foundation.h>
#import "PasterConstant.h"
#import "BLEModel.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark 蓝牙扫描协议
@protocol ScanPasterDelegate <NSObject>

@optional
///ConnectResultType: 设备连接结果
- (void) onScanResult:(BLEModel *) bleModel;

@end

#pragma mark 设备连接协议
@protocol PasterConnectDelegate <NSObject>

@optional
///ConnectResultType: 设备连接结果
- (void) onConnectResult:(ConnectResultType) connectResultType;

@end

#pragma mark 实时数据协议
@protocol RealTimeDataDelegate <NSObject>

@optional
- (void) onOpenRealTime:(BOOL) isOpenSuccess;
- (void) onRealTimeData:(NSMutableArray<NSNumber *> *) eegData;
- (void) onRealTimeFilterData:(NSMutableArray<NSNumber *> *)eegData;

@end

#pragma mark 数据截取协议
@protocol PickDataDelegate <NSObject>

@optional
- (void) onPickUpData:(NSMutableArray<NSNumber *> *) eegData second:(NSUInteger) second;

@end

#pragma mark 睡眠分期协议
@protocol OnlineStageDelegate <NSObject>

@optional
- (void) onlineStage:(NSUInteger) stage;

@end

#pragma mark 睡眠实时数据协议
@protocol RealIndexDelegate <NSObject>

- (void) realIndexListener:(NSArray<NSNumber *> *) indexArray;

@end

#pragma mark 数据采集协议
@protocol RecordDelegate <NSObject>

@optional
///
- (void) onStartRecordWithPath:(NSString *) edfPath;
- (void) onRecordingEEG:(NSMutableArray<NSNumber *> *) eegArray accel:(NSMutableArray<NSNumber *> *) accelArray gyro:(NSMutableArray<NSNumber *> *) gyroArray;
- (void) onStopRecord;
- (void) onRecordFailure:(RecordEventError) recordError;
- (void) onRecordEventResult:(NSInteger) eventResult;
- (void) onReturnUID:(NSString *) uid user:(NSString *) user edfName:(NSString *) edfName;

@end

#pragma mark 冥想协议
@protocol MeditationDelegate <NSObject>
///接收到冥想分数，0.5秒1次
- (void) onMeditationScore:(CGFloat) score;
@end

#pragma mark 离线数据
@protocol OfflineDataDelegate <NSObject>
- (void) queryOfflineResultWithUid:(NSString *) uid;
- (void) mergeOfflineDataWithEdf:(NSString *) edfName progress:(float)progress step:(NSInteger)code;

@end

@interface PasterListener : NSObject

@end

NS_ASSUME_NONNULL_END
