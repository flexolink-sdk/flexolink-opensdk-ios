//
//  DeviceModel.h
//  PasterSDK
//
//  Created by frank on 2023/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceModel : NSObject

@property(nonatomic, copy) NSString* name;
@property(nonatomic, assign) BOOL isConnected;
@end


NS_ASSUME_NONNULL_END
