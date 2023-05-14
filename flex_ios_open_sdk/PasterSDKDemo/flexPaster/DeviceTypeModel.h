//
//  PWDeviceTypeModel.h
//  AirDream
//
//  Created by eric on 2022/9/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceTypeModel : NSObject
///协议版本
@property(nonatomic, copy) NSString* version;
///协议 sn
@property(nonatomic, copy) NSString* sn;
///设备类型
@property(nonatomic, copy) NSString* deviceType;
///设备名称
@property(nonatomic, copy) NSString* deviceName;
@end

NS_ASSUME_NONNULL_END
