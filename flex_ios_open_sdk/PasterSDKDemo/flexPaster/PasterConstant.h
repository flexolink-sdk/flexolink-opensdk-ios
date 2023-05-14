//
//  PasterConstant.h
//  PasterSDK
//
//  Created by frank on 2023/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ConnectResultType){
    ConnectResultSuccess,
    ConnectResultFaild = 1,
};

typedef NS_ENUM(NSUInteger, RecordEventError){
    sexFormatError,
    birthdayFormatError = 1,
    ageFormatError = 2,
    nameFormatError = 3,
    EDFPathError = 4,
    deviceNameFormatError = 5,
    createEDFFileError = 6,
};

typedef void(^AuthCallback) (BOOL isSuccess, NSArray *sdkList);


@interface PasterConstant : NSObject

@end

NS_ASSUME_NONNULL_END
