//
//  ViewController.m
//  WCYRecordTrimDemo
//
//  Created by wangchangyang on 2017/2/20.
//  Copyright © 2017年 wangchangyang. All rights reserved.
//

#import "ViewController.h"
#import "WCYTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "WCYDetailViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate>

@property (nonatomic, strong) NSArray *source;
@property (nonatomic, copy) NSString *doctPath;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, assign) NSUInteger index;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self loadSource];
}

- (void)loadSource {
    self.source = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.doctPath error:nil];
    [self.tableView reloadData];
}

- (NSString *)doctPath {
    if (!_doctPath) {
        _doctPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    }
    return _doctPath;
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
    
    BOOL isDir;
    [[NSFileManager defaultManager] fileExistsAtPath:[self.doctPath stringByAppendingPathComponent:path] isDirectory:&isDir];
//    label.hidden = isDir;
    [cell.contentView viewWithTag:11].hidden = isDir;
    [cell.contentView viewWithTag:12].hidden = isDir;
    
    __weak typeof(self) weakSelf = self;
    cell.block = ^(NSUInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (index == 11) {  // 如果是 trim
            [strongSelf trimAudio:indexPath.row];
        } else {            // 如果是 play
            [strongSelf playAudio:indexPath.row];
        }
    };
    return cell;
}

// 默认中间分割
- (void)trimAudio:(NSUInteger)index {
    NSURL *url = [NSURL fileURLWithPath:[self.doctPath stringByAppendingPathComponent:self.source[index]]];
    AVAsset *asset = [AVAsset assetWithURL:url];
    CMTime assetTime = asset.duration;
    Float64 duration = CMTimeGetSeconds(assetTime);
    if (duration == 0) {
        return;
    }
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    if (!track) {
        return;
    }
    
    AVAssetExportSession *export = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    if (!export) {
        return;
    }
    
    // 声音的 起止 时间
    CMTime startTime = kCMTimeZero;
    CMTime endTime = CMTimeMakeWithSeconds(duration * 0.5, 1);
    
    // Fade in time
    CMTime fadeStart = kCMTimeZero;
    CMTime fadeEnd = CMTimeMakeWithSeconds(duration * 0.5, 1);
    CMTimeRange fadeInTimeRange = CMTimeRangeFromTimeToTime(fadeStart, fadeEnd);
    
    
    AVMutableAudioMixInputParameters *para = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [para setVolumeRampFromStartVolume:1 toEndVolume:0 timeRange:fadeInTimeRange];
    
    AVMutableAudioMix *exportAudiMix = [AVMutableAudioMix audioMix];
    exportAudiMix.inputParameters = @[para];
    
    NSString *parentDir = [self.doctPath stringByAppendingPathComponent:[self.source[index] stringByDeletingPathExtension]];
    BOOL isDir;
    [[NSFileManager defaultManager] fileExistsAtPath:parentDir isDirectory:&isDir];
    if (!isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:parentDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSUInteger cnt = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:parentDir error:nil] count];
    
    NSString *outputPath = [parentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", @(cnt)]];
    
    export.outputURL = [NSURL fileURLWithPath:outputPath];
    export.outputFileType = AVFileTypeAppleM4A;
    export.timeRange = CMTimeRangeFromTimeToTime(startTime, endTime);
    export.audioMix = exportAudiMix;
    [export exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@", @(export.status));
        [self loadSource];
    }];
}

- (void)playAudio:(NSUInteger)index {
    NSString *fileName = [NSString stringWithFormat:@"%@", self.source[index]];
    NSString *path = [self.doctPath stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    _player = player;
    [_player play];
}


- (IBAction)recordStart:(UIButton *)sender {
    _index = self.source.count;
    NSString *fileName = [NSString stringWithFormat:@"%@.aac", @(_index)];
    NSString *savePath = [self.doctPath stringByAppendingPathComponent:fileName];
    NSError *recodError = nil;
    NSDictionary *dict
    = @{AVFormatIDKey:              @(kAudioFormatMPEG4AAC),
        AVSampleRateKey:            @(44100),
        AVNumberOfChannelsKey:      @(1),
        AVLinearPCMBitDepthKey:     @(16),
        AVEncoderAudioQualityKey:   @(AVAudioQualityHigh)};
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:savePath]
                                                           settings:dict error:&recodError];
    _recorder = recorder;
    _recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [_recorder record];
}

- (IBAction)recordEnd:(UIButton *)sender {
    [_recorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        [self loadSource];
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"detail" sender:@(indexPath.row)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detail"]) {
        WCYDetailViewController *vc = (WCYDetailViewController *)segue.destinationViewController;
        vc.filePath = self.source[[sender unsignedIntegerValue]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
