//
//  AppDelegate.m
//  PasterSDK
//
//  Created by frank on 2023/1/30.
//

#import "AppDelegate.h"
#import "FlexPasterSDK.h"
#import <CommonCrypto/CommonCryptor.h>
#import "AES.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "RNCryptor.h"

@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dnn_1122_qiyuan_250HZ_4class_30s_1.ncnn" ofType:@"param"];
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    NSString *fileContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//    NSString *deTest = [AES decryptAES:fileContent key:@"EA963936F004A5CC17B43B5DD92CE9F0" initialVector:@"648E86CFDAC3047387E42A13CAE4382C" keySize:kWMKeySizeAES128];
//    NSLog(@"%s:%@",__func__,deTest);
    
//    NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:filePath];
//    NSData *data = [fh readDataToEndOfFile];
////            NSLog(@"NSFileHandle实例读取的内容是：\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//    NSData *decData = [self AES128DecryptWithKey:@"EA963936F004A5CC17B43B5DD92CE9F0" gIv:@"648E86CFDAC3047387E42A13CAE4382C" data:data];
//
//    NSLog(@"%@", [[NSString alloc] initWithData:decData encoding:NSUTF8StringEncoding]);
    
//    NSString *binSourcePath = [[NSBundle mainBundle] pathForResource:@"dnn_1122_qiyuan_250HZ_4class_30s_1.ncnn" ofType:@"bin"];
//    NSString *binDestName = @"sleep_m_0310.b";
//    [self EncryptWithSource:binSourcePath dest:binDestName];
//
//    NSString *paramSourcePath = [[NSBundle mainBundle] pathForResource:@"dnn_1122_qiyuan_250HZ_4class_30s_1.ncnn" ofType:@"param"];
//    NSString *paramDestName = @"sleep_m_0310.p";
//    [self EncryptWithSource:paramSourcePath dest:paramDestName];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (NSData *)AES128DecryptWithKey:(NSString *)key gIv:(NSString *)Iv data:(NSData *) data {
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [Iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

#pragma  mark --加密
- (void) EncryptWithSource:(NSString *) sourceFilePath dest:(NSString *) destFileName {

    NSData *data = [NSData dataWithContentsOfFile:sourceFilePath];
    NSError *error;

    //加密
    NSData *encryptedData = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:@"1lfolqod945ofijs" error:&error ];

    if (!error) {
        NSLog(@"加密成功");

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:destFileName];
        
        if (![[NSFileManager defaultManager ] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }

        [encryptedData writeToFile:filePath atomically:YES];
        
    }
}
-(void)imageEncryptionAndDecryption
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dnn_1122_qiyuan_250HZ_4class_30s_1.ncnn" ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;

    //加密
    NSData *encryptedData = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:@"1lfolqod945ofijs" error:&error ];

    if (!error) {
        NSLog(@"加密成功");

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:@"sleep_m_0310.b"];
        
        if (![[NSFileManager defaultManager ] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }

        [encryptedData writeToFile:filePath atomically:YES];
        
    }
    
//    //解密
//    NSData *decryptedData = [RNDecryptor decryptData:data withPassword:@"123456" error:&error];
//    if (!error) {
//        NSLog(@"^_^ 解密成功 ……——(^_^)\n");
////        NSLog(@"decryptedData==%@",decryptedData);
//
////        self.imageView.image = [UIImage imageWithData:decryptedData];
//        NSString *str = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
//
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//        NSString *documentDirectory = [paths objectAtIndex:0];
//        NSString *filePath = [documentDirectory stringByAppendingPathComponent:@"/dnn_1122_qiyuan_250HZ_4class_30s_7.ncnn"];
//        NSError * error;
//        if (![[NSFileManager defaultManager ] fileExistsAtPath:filePath]) {
//            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
//        }
//
//        [decryptedData writeToFile:filePath atomically:YES];
//        NSLog(@"");
//    }
}

@end
