//
//  QHBluetoothModel.h
//  AirDream
//
//  Created by Larry.Leng on 2022/2/25.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLEModel : NSObject

/** 外围设备 */
@property (nonatomic, strong) CBPeripheral *peripheralObj;

@property (nonatomic, strong) NSDictionary<NSString *, id> *adverData;
    
/** 信号 */
@property (nonatomic, strong) NSNumber *RSSI;

/** 服务 */
@property (nonatomic, strong) CBService *service;

/** 特证 */
@property (nonatomic, strong) CBCharacteristic *charac;

/** 错误信息 */
@property (nonatomic, strong) NSError *error;

/** 蓝牙设备的名字 */
@property (nonatomic, copy) NSString *deviceName;

@property(nonatomic, assign) BOOL isConneced;
//

@end

NS_ASSUME_NONNULL_END
