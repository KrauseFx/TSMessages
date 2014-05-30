//
//  TSMessage+Sounds.h
//
//  Created by Jesse Cox on 5/15/14.
//
//

#import "TSMessage.h"

@protocol TSMessageSoundDelegate <TSMessageDelegate>

@optional
- (NSString *)soundForNotificationType:(TSMessageType)type;

@end

@interface TSMessageSoundPlayer : NSObject

+(TSMessageSoundPlayer*)sharedPlayer;
- (void)playSoundWithName:(NSString *)name;

@end