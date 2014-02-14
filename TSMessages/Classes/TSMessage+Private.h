//
//  TSMessage+Private.h
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "TSMessage.h"

@class TSMessageView;

@interface TSMessage (Private)
- (void)fadeOutCurrentNotification;
- (void)fadeOutNotification:(TSMessageView *)messageView;
- (void)fadeOutNotification:(TSMessageView *)messageView completion:(void (^)())completion;
- (TSMessageView *)currentNotification;
@end