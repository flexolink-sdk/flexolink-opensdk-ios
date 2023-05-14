//
//  PWMD5Utilities.m
//  FundManager
//
//  Created by inter on 2018/10/22.
//  Copyright © 2018年 com.shangyu.fund. All rights reserved.
//

#import "PWMD5Utilities.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PWMD5Utilities
+ (NSString *)md5HexDigest:(NSString *)url
{
    const char *original_str = [url UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( original_str, (CC_LONG)strlen(original_str), result );

    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];}

+ (NSString *)md5StrXor:(NSString *)str {
    const char *myPasswd = [str UTF8String];
    //1byte = 8bit 4bit可以表示一个16进制数
    unsigned char mdc[16];
    CC_MD5(myPasswd, (CC_LONG)strlen(myPasswd), mdc);
    NSMutableString *md5String = [NSMutableString string];
    [md5String appendFormat:@"%02x",mdc[0]];
    for (int i = 1; i < 16; i++) {
        [md5String appendFormat:@"%02x",mdc[i]^mdc[0]];
    }
    return [md5String lowercaseString];
}
@end
