//
//  TSMessageView+Private.h
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessageView.h"

#if defined(__has_include)
#if __has_include("TSMessage+Sounds.h")
#include "TSMessage+Sounds.h"
#define kCanPlaySounds YES
#else
#define kCanPlaySounds NO
#endif
#endif

#define kTSMessagePlaySound @"TSMessagePlaySound"

@interface TSMessageView (Private)
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) CGPoint centerForDisplay;
@property (nonatomic, assign, getter=isMessageFullyDisplayed) BOOL messageFullyDisplayed;

- (void)prepareForDisplay;
@end
