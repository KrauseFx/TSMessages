//
//  TSMessage+Sounds.h
//
//  Created by Jesse Cox on 5/15/14.
//
//

#import "TSMessage.h"

@interface TSMessage (Sounds)

/** Use this method to set a sound that will be played with all messages, or a fallback for messages that do not have an associated sound */
+ (void)setNotificationSoundWithName:(NSString*)name andExtension:(NSString*)extension;

/** Use this method to set default sound to be used with a particular TSMessageType */
+ (void)setSoundWithName:(NSString*)name extension:(NSString*)extension forNotificationType:(TSMessageType)notificationType;

@end


@interface TSMessageSoundPlayer : NSObject

- (void)playSoundForMessage:(NSNotification*)messageObject;

@end