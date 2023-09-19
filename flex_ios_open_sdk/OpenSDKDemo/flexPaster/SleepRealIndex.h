//
//  SleepRealIndex.h
//  SleepRealIndex
//
//  Created by frank on 2023/7/8.
//

#import <Foundation/Foundation.h>

@interface SleepRealIndex : NSObject
///睡眠实时指数
///eegArray 脑电原始数据
///deviceType 设备类型，比如 Flex-BM05
+ (NSDictionary *)realIndexWith:(NSMutableArray<NSNumber *> *)eegArray deviceType:(NSString *) deviceType;

@end
