//
//  TSMessage.h
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TSMessageNotificationTypeMessage = 0,
    TSMessageNotificationTypeWarning,
    TSMessageNotificationTypeError,
    TSMessageNotificationTypeSuccess
} TSMessageNotificationType;

typedef enum {
    TSMessageNotificationPositionTop = 0,
    TSMessageNotificationPositionBottom
} TSMessageNotificationPosition;

/** This enum can be passed to the duration parameter */
typedef enum {
    TSMessageNotificationDurationAutomatic = 0,
    TSMessageNotificationDurationEndless = -1 // The notification is displayed until the user dismissed it or it is dismissed by calling dismissActiveNotification
} TSMessageNotificationDuration;


@interface TSMessage : NSObject

+ (instancetype)sharedMessage;

/** Indicates whether a notification is currently active. */
+ (BOOL)isNotificationActive;

/** Shows a notification message 
 @param message The title of the notification view
 @param type The notification type (Message, Warning, Error, Success)
 */
+ (void)showNotificationWithMessage:(NSString *)message
                           withType:(TSMessageNotificationType)type;

/** Shows a notification message
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 */
+ (void)showNotificationWithTitle:(NSString *)title
                      withMessage:(NSString *)message
                         withType:(TSMessageNotificationType)type;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 @param duration The duration of the notification being displayed
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 @param duration The duration of the notification being displayed
 @param callback The block that should be executed, when the user tapped on the message
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration
                            withCallback:(void (^)())callback;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 @param duration The duration of the notification being displayed
 @param callback The block that should be executed, when the user tapped on the message
 @param position The position of the message on the screen
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration
                            withCallback:(void (^)())callback
                              atPosition:(TSMessageNotificationPosition)messagePosition;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 @param duration The duration of the notification being displayed
 @param callback The block that should be executed, when the user tapped on the message
 @param buttonTitle The title for button (optional)
 @param buttonCallback The block that should be executed, when the user tapped on the button
 @param position The position of the message on the screen
 @param dismissingEnabled Should the message be dismissed when the user taps/swipes it
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration
                            withCallback:(void (^)())callback
                         withButtonTitle:(NSString *)buttonTitle
                      withButtonCallback:(void (^)())buttonCallback
                              atPosition:(TSMessageNotificationPosition)messagePosition
                     canBeDismisedByUser:(BOOL)dismissingEnabled;


/** Fades out the currently displayed notification. If another notification is in the queue,
 the next one will be displayed automatically 
 @return YES if the currently displayed notification could be hidden. NO if no notification 
 was currently displayed.
 */
+ (BOOL)dismissActiveNotification;



/** Shows a predefined error message, that is displayed, when this action requires an internet connection */
+ (void)showInternetError;

/** Shows a predefined error message, that is displayed, when this action requires location services */
+ (void)showLocationError;




/** Implement this in subclass to set a default view controller */
+ (UIViewController *)defaultViewController;

/** Can be implemented differently in subclass. Is used to define the top position from which the notification flies in from */
+ (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController;

@end
