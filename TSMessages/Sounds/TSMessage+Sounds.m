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

__strong static AVAudioPlayer *_notificationSound;
__strong static AVAudioPlayer *_defaultSound;
__strong static AVAudioPlayer *_warningSound;
__strong static AVAudioPlayer *_errorSound;
__strong static AVAudioPlayer *_successSound;

@implementation TSMessage (Sounds)


+ (void)setNotificationSoundWithName:(NSString *)name andExtension:(NSString *)extension
{
    _notificationSound = [[TSMessage sharedMessage] loadSound:name extension:extension];
}


+ (void)setSoundWithName:(NSString*)name extension:(NSString*)extension forNotificationType:(TSMessageType)notificationType {
    switch (notificationType) {
        case TSMessageTypeDefault:
            _defaultSound = [[TSMessage sharedMessage] loadSound:name extension:extension];
            break;
        case TSMessageTypeWarning:
            _warningSound =[[TSMessage sharedMessage] loadSound:name extension:extension];
            break;
        case TSMessageTypeError:
            _errorSound = [[TSMessage sharedMessage] loadSound:name extension:extension];
            break;
        case TSMessageTypeSuccess:
            _successSound = [[TSMessage sharedMessage] loadSound:name extension:extension];
            break;
        default:
            break;
    }
}


- (AVAudioPlayer *)loadSound:(NSString *)filename extension:(NSString *)extension
{
    [TSMessageSoundPlayer initialize];
    NSURL * url = [[NSBundle mainBundle] URLForResource:filename withExtension:extension];
    NSError * error;
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!player) {
        NSLog(@"Error loading %@: %@", url, error.localizedDescription);
    } else
    {
        {
            [player prepareToPlay];
        }
    }
    return player;
}


@end

@implementation TSMessageSoundPlayer

+ (void)initialize {
	[TSMessageSoundPlayer sharedInstance];
}

+(TSMessageSoundPlayer*)sharedInstance
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
    	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playSoundForMessage:) name:kTSMessagePlaySound object:nil];
    }
    return self;
}

- (void)playSoundForMessage:(NSNotification*)messageObject {
    TSMessageView *messageView = messageObject.object;
    switch (messageView.type) {
        case TSMessageTypeDefault:
            if (_defaultSound) {
                [_defaultSound play];
            } else if (_notificationSound)
                [_notificationSound play];
            break;
        case TSMessageTypeWarning:
            if (_warningSound) {
                [_warningSound play];
            } else if (_notificationSound) {
                [_notificationSound play];
            }
            break;
        case TSMessageTypeError:
            if (_errorSound) {
                [_errorSound play];
            } else if (_notificationSound) {
                [_notificationSound play];
            }
            break;
        case TSMessageTypeSuccess:
            if (_successSound) {
                [_successSound play];
            } else if (_notificationSound) {
                [_notificationSound play];
            }
            break;
        default:
            break;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTSMessagePlaySound object:nil];
    [super dealloc];
}
@end