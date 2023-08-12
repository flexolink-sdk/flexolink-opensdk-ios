//
//  UserInfoModel.h
//  PasterSDK
//
//  Created by frank on 2023/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoModel : NSObject
///用户姓名
@property(nonatomic, copy) NSString* name;
///生日日期
@property(nonatomic, copy) NSString* birthday;
///性别
@property(nonatomic, copy) NSString* sex;
///设备名称
@property(nonatomic, copy) NSString* deviceName;
@end

NS_ASSUME_NONNULL_END
