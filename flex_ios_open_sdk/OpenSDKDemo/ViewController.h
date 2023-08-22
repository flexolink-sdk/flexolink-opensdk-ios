//
//  ViewController.h
//  PasterSDK
//
//  Created by frank on 2023/1/30.
//

#import <UIKit/UIKit.h>
@class ApiModel;

@interface ViewController : UIViewController

@end

@interface ApiModel : NSObject
@property(nonatomic, copy) NSString* showTitle;
///api 名称
@property(nonatomic, copy) NSString* action;
///是否已经授权
@property(nonatomic, assign) BOOL isAuthority;


- (instancetype) initWithShowTitle:(NSString *) showTitle action:(NSString *) action;

@end

