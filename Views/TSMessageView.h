//
//  TSMessageView.h
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessage.h"

#define TSMessageViewAlpha 0.95

@interface TSMessageView : UIView

@property (nonatomic, strong) UISwipeGestureRecognizer *gestureRec;
@property (nonatomic, strong) UITapGestureRecognizer *tapRec;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

/** Inits the notification view */
- (id)initWithTitle:(NSString *)title withContent:(NSString *)content withType:(notificationType)notificationType;

/** Fades out this notification view */
- (void)fadeMeOut;

@end
