//
//  AudioHelper.m
//  OpenSDKDemoDemo
//
//  Created by frank on 2024/3/18.
//

#import "AudioHelper.h"

#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVPlayerItem.h>

@interface AudioHelper ()<AVAudioPlayerDelegate>
@property(nonatomic, strong) AVAudioPlayer* audioPlay;
@end

@implementation AudioHelper

- (void) playerWithFilePath:(NSString *) filePath {
    NSURL *url  = [NSURL fileURLWithPath:filePath];
    NSError *audioError;
    self.audioPlay = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&audioError];
    
    if (audioError) {
        NSLog(@"error:%@", audioError.description);
    } else {
        self.audioPlay.numberOfLoops = -1;
        [self.audioPlay prepareToPlay];
        [self.audioPlay play];
        self.audioPlay.volume = 1;
        
        NSError *sessionError;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&sessionError];
        if (sessionError) {
            NSLog(@"error=%@", sessionError);
        }
    }
}

#pragma mark
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"");
}
- (void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"");
}

@end
