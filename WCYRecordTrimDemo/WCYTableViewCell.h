//
//  WCYTableViewCell.h
//  WCYRecordTrimDemo
//
//  Created by wangchangyang on 2017/2/20.
//  Copyright © 2017年 wangchangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FucBlock)(NSUInteger index);

@interface WCYTableViewCell : UITableViewCell

@property (nonatomic, copy) FucBlock block;

@property (nonatomic, assign) NSUInteger index;

@end
