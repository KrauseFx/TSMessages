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

/** Inits the notification view. Do not call this from outisde this library.
 @param title The title of the notification view
 @param content The subtitle/content of the notification view (optional)
 @param notificationType The type (color) of the notification view
 */
- (id)initWithTitle:(NSString *)title withContent:(NSString *)content withType:(notificationType)notificationType;

/** Fades out this notification view */
- (void)fadeMeOut;

@end
