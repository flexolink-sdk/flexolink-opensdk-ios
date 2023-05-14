//
//  PWMD5Utilities.h
//  FundManager
//
//  Created by inter on 2018/10/22.
//  Copyright © 2018年 com.shangyu.fund. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PWMD5Utilities : NSObject
+ (NSString *)md5HexDigest:(NSString *)url;
+ (NSString *)md5StrXor:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
