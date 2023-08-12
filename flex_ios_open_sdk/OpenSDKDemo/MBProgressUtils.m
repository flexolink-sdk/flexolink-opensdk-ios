//
//  MBProgressUtils.m
//  PasterSDK
//
//  Created by frank on 2023/2/3.
//

#import "MBProgressUtils.h"
#import "MBProgressHUD.h"

@implementation MBProgressUtils

+ (void) showMsg:(NSString *) msg view:(UIView *) view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
}
@end
