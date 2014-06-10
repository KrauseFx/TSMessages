//
//  TSMessage+TSMessage_Sounds.m
//  Pods
//
//  Created by Jesse Cox on 5/15/14.
//
//

#import "TSMessage+Sounds.h"
#import "TSMessageView+Private.h"
#import <AVFoundation/AVFoundation.h>

@implementation TSMessageSoundPlayer

+ (void)initialize {
	[TSMessageSoundPlayer sharedPlayer];
}

+(TSMessageSoundPlayer*)sharedPlayer
{
    static TSMessageSoundPlayer *sharedTSMessageSoundPlayerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTSMessageSoundPlayerInstance = [[self alloc]init];
    });
    return sharedTSMessageSoundPlayerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)playSoundWithName:(NSString *)name {
    
    NSString *title = [[name componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *extension = [[name componentsSeparatedByString:@"."] objectAtIndex:1];
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:title withExtension:extension]
                                                           fileTypeHint:extension
                                                                  error:&error];
    if (!player) {
        NSLog(@"Error loading %@: %@", name, error);
    } else {
        [player prepareToPlay];
    }
    [player play];
}

@end