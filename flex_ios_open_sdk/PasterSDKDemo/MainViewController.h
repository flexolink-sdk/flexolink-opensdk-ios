//
//  ViewController.h
//  PasterSDK
//
//  Created by frank on 2023/1/30.
//

#import <UIKit/UIKit.h>
@class Model;

@interface MainViewController : UIViewController


@end

@interface Model : NSObject
@property(nonatomic, copy) NSString* showTitle;
///api 名称
@property(nonatomic, copy) NSString* action;
///是否已经授权
@property(nonatomic, assign) BOOL isAuthority;


- (instancetype) initWithShowTitle:(NSString *) showTitle action:(NSString *) action;

@end

