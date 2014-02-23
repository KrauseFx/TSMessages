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
+ (NSMutableDictionary *)design;
- (void)dismissMessage:(TSMessageView *)messageView;
- (void)dismissMessage:(TSMessageView *)messageView completion:(void (^)())completion;
- (TSMessageView *)currentMessage;
@end