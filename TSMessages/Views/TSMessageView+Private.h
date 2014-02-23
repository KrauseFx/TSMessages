//
//  TSMessageView+Private.h
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessageView.h"

@interface TSMessageView (Private)
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) CGPoint centerForDisplay;
@property (nonatomic, assign, getter=isMessageFullyDisplayed) BOOL messageFullyDisplayed;

- (void)prepareForDisplay;
@end
