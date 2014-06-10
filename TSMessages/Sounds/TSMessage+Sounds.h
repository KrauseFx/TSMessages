//
//  TSMessage+Sounds.h
//
//  Created by Jesse Cox on 5/15/14.
//
//

#import "TSMessage.h"

/**
    The TSMessageSoundDelegate protocol extends the TSMessageDelegate protocol, and allows a sound to be played when a message is displayed. The single optional method returns a string containing the filename of the sound to be played. You can choose to define one filename to return for all messages, or use a switch statement to return a different filename for each TSMessageType.
*/
@protocol TSMessageSoundDelegate <TSMessageDelegate>

@optional
/** Returns a string containing the filename of a sound to be played when a message is displayed. Can return a different filename for each TSMessageType. */
- (NSString *)soundForNotificationType:(TSMessageType)type;

@end

@interface TSMessageSoundPlayer : NSObject

+(TSMessageSoundPlayer*)sharedPlayer;
- (void)playSoundWithName:(NSString *)name;

@end