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

@protocol TSMessageViewProtocol<NSObject>
@optional
/** Can be implemented differently. Is used to define the top position from which the notification flies in from */
- (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController;
@end

@interface TSMessageView : UIView

+ (NSMutableDictionary *)notificationDesign;

/** Use this method to load a custom design file */
+ (void)addNotificationDesignFromFile:(NSString *)file;

/** The displayed title of this message */
@property (nonatomic, readonly) NSString *title;

/** The displayed content of this message (optional) */
@property (nonatomic, readonly) NSString *content;

/** The view controller this message is displayed in */
@property (nonatomic, readonly) UIViewController *viewController;

/** The duration of the displayed message. If it is 0.0, it will automatically be calculated */
@property (nonatomic, assign) CGFloat duration;

/** The position of the message (top or bottom) */
@property (nonatomic, assign) TSMessageNotificationPosition messagePosition;

/** Is the message currenlty fully displayed? Is set as soon as the message is really fully visible */
@property (nonatomic, assign) BOOL messageIsFullyDisplayed;

@property(nonatomic, assign) id <TSMessageViewProtocol> delegate;

/** Inits the notification view. Do not call this from outside this library.
 @param title The title of the notification view
 @param content The subtitle/content of the notification view (optional)
 @param notificationType The type (color) of the notification view
 @param duration The duration this notification should be displayed (optional)
 @param viewController The view controller this message should be displayed in
 @param callback The block that should be executed, when the user tapped on the message
 @param buttonTitle The title for button (optional)
 @param buttonCallback The block that should be executed, when the user tapped on the button
 @param position The position of the message on the screen
 @param dismissAble Should this message be dismissed when the user taps/swipes it?
 */
- (id)initWithTitle:(NSString *)title
        withContent:(NSString *)content
           withType:(TSMessageNotificationType)notificationType
       withDuration:(CGFloat)duration
   inViewController:(UIViewController *)viewController
       withCallback:(void (^)())callback
    withButtonTitle:(NSString *)buttonTitle
 withButtonCallback:(void (^)())buttonCallback
         atPosition:(TSMessageNotificationPosition)position
  shouldBeDismissed:(BOOL)dismissAble;

/** Fades out this notification view */
- (void)fadeMeOut;

@end
