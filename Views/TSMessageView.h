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

/** The displayed title of this message */
@property (nonatomic, readonly) NSString *title;
/** The displayed content of this message (optional) */
@property (nonatomic, readonly) NSString *content;
/** The view controller this message is displayed in */
@property (nonatomic, readonly) UIViewController *viewController;
/** The duration of the displayed message. If it is 0.0, it will automatically be calculated */
@property (nonatomic, assign) CGFloat duration;

/** Inits the notification view. Do not call this from outisde this library.
 @param title The title of the notification view
 @param content The subtitle/content of the notification view (optional)
 @param notificationType The type (color) of the notification view
 @param duration The duration this notification should be displayed (optional)
 @param viewController The view controller this message should be displayed in
 @param callback The block that should be executed, when the user tapped on the message
 */
- (id)initWithTitle:(NSString *)title
        withContent:(NSString *)content
           withType:(TSMessageNotificationType)notificationType
       withDuration:(CGFloat)duration
   inViewController:(UIViewController *)viewController
       withCallback:(void (^)())callback;

/** Fades out this notification view */
- (void)fadeMeOut;

@end
