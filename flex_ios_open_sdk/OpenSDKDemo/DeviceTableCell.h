//
//  DeviceTableCell.h
//  PasterSDK
//
//  Created by frank on 2023/2/3.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
#import "BLEModel.h"
@class DeviceTableCell;

NS_ASSUME_NONNULL_BEGIN

@protocol DeviceTableCellDelagate <NSObject>

- (void) deviceTableCell:(DeviceTableCell *) cell btnIndex:(NSInteger) index isConnected:(BOOL) isConnected;

@end

@interface DeviceTableCell : UITableViewCell

@property(nonatomic, strong) BLEModel* model;
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, weak) id<DeviceTableCellDelagate> delegate;
@end

NS_ASSUME_NONNULL_END
