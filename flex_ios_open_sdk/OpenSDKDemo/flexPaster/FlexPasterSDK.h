//
//  PasterSDK.h
//  PasterSDK
//
//  Created by frank on 2023/1/30.
//

#import <Foundation/Foundation.h>
#import "PasterListener.h"
#import "PasterConstant.h"
#import "UserInfoModel.h"
#import "BLEModel.h"
#import "DeviceModel.h"
#import "DeviceTypeModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface FlexPasterSDK : NSObject

+ (instancetype) sharedInstance;

///开始扫描
- (void) startScan:(id<ScanPasterDelegate>) scanPasterDelegate;
///停止扫描
- (void) stopScan;
///连接设备
- (void) connectBleDevice:(id<PasterConnectDelegate>) connectDelegate connectName:(NSString *) name;
- (void) connectBleDevice:(id<PasterConnectDelegate>) connectDelegate connectPeripheral:(BLEModel *) model;
///关闭设备连接
- (void) closeBleDevice;
///设备是否连接
- (BOOL) isConnected;

///设备电量
- (NSUInteger) battery;
///信号强度
- (NSInteger) deviceRSSI;
///是否佩戴
- (BOOL) isWearPatch;
///
- (NSUInteger) bodyPosition;

///实时数据监听
- (void) realDataListener:(id<RealTimeDataDelegate>) realTimeDelegate;
///数据截取
- (void) pickupDataListener:(id<PickDataDelegate>) pickDataDelegate second:(NSUInteger) second;
- (void) pickupDataBySecond:(NSUInteger) second;
///滤波参数
- (void) filterParam:(NSUInteger) order hp:(NSInteger) hp lp:(NSInteger) lp;
///开始记录
- (void) startRecordWithEdfName:(NSString *) edfPath userInfo:(UserInfoModel *) userInfo;
- (void) startRecordWithEdfName:(NSString *) edfPath userInfo:(UserInfoModel *) userInfo recordDelegate:(nonnull id<RecordDelegate>)recordDelegate;
///结束记录
- (void) stopRecord;
///添加事件
- (void) addEdfEventWithStartTime:(NSDate *) startTime endTime:(NSDate *) endTime eventContent:(NSString *) eventContent;
- (void) addEdfEventWithStartTime:(long long) startTimeStamp duration:(long long) duration eventContent:(NSString *) eventContent;
///信号质量
- (BOOL) signalQualityWithData:(NSMutableArray<NSNumber *> *) data dataLen:(NSUInteger) dataLen;
///分期状态
- (void) onlineStage:(id<OnlineStageDelegate>) onlineStageDelegate binPath:(NSString *) binPath paramPath:(NSString *) paramPath;
///设备信息
- (DeviceTypeModel *) deviceInfo;

- (void) setRealListener:(id<RealIndexDelegate>)listener deviceType:(NSString *)deviceType;

///开始冥想
- (void) startMeditationWith:(id<MeditationDelegate>) meditationDelegate;
///结束冥想
- (void) stopMeditation;

/// sdk 授权
- (void) authorityWithAppKey:(NSString *) appKey appSecret:(NSString *) appSecret block:(AuthCallback) block;


@end

NS_ASSUME_NONNULL_END
