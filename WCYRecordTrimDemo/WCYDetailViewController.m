//
//  WCYDetailViewController.m
//  WCYRecordTrimDemo
//
//  Created by wangchangyang on 2017/2/20.
//  Copyright © 2017年 wangchangyang. All rights reserved.
//

#import "WCYDetailViewController.h"
#import "WCYTableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@interface WCYDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *source;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, copy) NSString *doctPath;

@end

@implementation WCYDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSource];
}

- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
}

- (void)loadSource {
    NSString *path = [self.doctPath stringByAppendingPathComponent:self.filePath];
    NSError *error = nil;
    self.source = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.source.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"cell";
    WCYTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
    NSString *path = self.source[indexPath.row];
    label.text = [NSString stringWithFormat:@"%@", path];
    
    __weak typeof(self) weakSelf = self;
    cell.block = ^(NSUInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (index == 11) {  // 如果是 trim
            
        } else {            // 如果是 play
            NSString *fileName = [self.filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.source[indexPath.row]]];
            NSString *path = [self.doctPath stringByAppendingPathComponent:fileName];
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            NSError *error = nil;
            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
            strongSelf.player = player;
            [strongSelf.player play];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)doctPath {
    if (!_doctPath) {
        _doctPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    }
    return _doctPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
