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
    TSMessageNotificationTypeSuccessful
} TSMessageNotificationType;

@interface TSMessage : NSObject

/** The view controller the messages should be displayed in */
@property (strong, nonatomic) UIViewController *viewController;

+ (instancetype)sharedMessage;

/** Shows a notification message 
 @param message The title of the notification view
 @param type The notification type (Message, Warning, Error, Successful)
 */
+ (void)showNotificationWithMessage:(NSString *)message
                           withType:(TSMessageNotificationType)type;

/** Shows a notification message
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Successful)
 */
+ (void)showNotificationWithTitle:(NSString *)title
                      withMessage:(NSString *)message
                         withType:(TSMessageNotificationType)type;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Successful)
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Successful)
 @param duration The duration of the notification being displayed
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration;


/** Shows a predefined error message, that is displayed, when this action requires an internet connection */
+ (void)showInternetError;

/** Shows a predefined error message, that is displayed, when this action requires location services */
+ (void)showLocationError;




/** Implement this in subclass to set the correct view controller */
+ (UIViewController *)getViewController;

/** Can be implemented differently in subclass. Is used to define the top position from which the notification flies in from */
+ (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController;

@end
