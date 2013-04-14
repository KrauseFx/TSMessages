//
//  TSMessage.h
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TSMessageAnimationDuration 0.3

typedef enum {
    kNotificationMessage = 0,
    kNotificationWarning,
    kNotificationError,
    kNotificationSuccessful
} notificationType;

@interface TSMessage : NSObject


@property (nonatomic, strong) NSMutableArray *messages;

@property (strong, nonatomic) UIViewController *viewController;

+ (TSMessage *)sharedNotification;

/** Shows a notification message 
 @param message The title of the notification view
 @param type The notification type (Message, Warning, Error, Successful)
 */
+ (void)showNotificationWithMessage:(NSString *)message
                           withType:(notificationType)type;

/** Shows a notification message
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Successful)
 */
+ (void)showNotificationWithTitle:(NSString *)title
                      withMessage:(NSString *)message
                         withType:(notificationType)type;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param message The message that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Successful)
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(notificationType)type;


/** Shows a predefined error message, that is displayed, when this action requires an internet connection */
+ (void)showInternetError;

/** Shows a predefined error message, that is displayed, when this action requires location services */
+ (void)showLocationError;




/** Implement this in subclass to set the correct view controller */
+ (UIViewController *)getViewController;

/** Can be implemented differently in subclass. Is used to define the top position from which the notification flies in from */
+ (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController;

@end
