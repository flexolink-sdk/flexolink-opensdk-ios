//
//  DeviceTableCell.m
//  PasterSDK
//
//  Created by frank on 2023/2/3.
//

#import "DeviceTableCell.h"

@interface DeviceTableCell ()

@property(nonatomic, strong) UILabel* nameLabel;
@property(nonatomic, strong) UIButton* connectBtn;
@property(nonatomic, strong) UILabel* statusLabel;

@end

@implementation DeviceTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self setupContentView];
    }
    return self;
}

- (void) setupContentView {
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.connectBtn];
    
}

#pragma mark 懒加载
- (UILabel *) nameLabel {
    if (!_nameLabel) {
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 200, 20)];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        
    }
    
    return _nameLabel;
}

- (UILabel *) statusLabel {
    if (!_statusLabel) {
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60-60, 20, 60, 20)];
        _statusLabel.textColor = [UIColor blackColor];
        _statusLabel.font = [UIFont systemFontOfSize:12];
        _statusLabel.text = @"已连接";
    }
    
    return _statusLabel;
}

- (UIButton *) connectBtn {
    if (!_connectBtn) {
        
        _connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _connectBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_connectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_connectBtn setTitle:@"连接" forState:UIControlStateNormal];
        _connectBtn.frame = CGRectMake(self.frame.size.width-60, 20, 60, 20);
        _connectBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _connectBtn.layer.borderWidth = 0.5;
        [_connectBtn addTarget:self action:@selector(connectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _connectBtn;
}

#pragma mark 外部方法
- (void) setModel:(BLEModel *)model {
    
    _model = model;
    
    self.nameLabel.text = model.peripheralObj.name;
    
    if (model.isConneced) {
        self.statusLabel.text = @"已连接";
        [self.connectBtn setTitle:@"断开连接" forState:UIControlStateNormal];
        
    } else {
        
        self.statusLabel.text = @"未连接";
        [self.connectBtn setTitle:@"连接" forState:UIControlStateNormal];
        
    }
    
}

#pragma mark 事件
- (void) connectBtnAction:(UIButton *) sender {
    
    if (self.delegate) {
        
        if ([self.delegate respondsToSelector:@selector(deviceTableCell:btnIndex:isConnected:)]) {
            
            [self.delegate deviceTableCell:self btnIndex:self.index isConnected:self.model.isConneced];
        }
    }
}
@end
