//
//  WCYTableViewCell.m
//  WCYRecordTrimDemo
//
//  Created by wangchangyang on 2017/2/20.
//  Copyright © 2017年 wangchangyang. All rights reserved.
//

#import "WCYTableViewCell.h"

@implementation WCYTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)btnClicked:(UIButton *)sender {    
    if (_block) {
        _block(sender.tag);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
