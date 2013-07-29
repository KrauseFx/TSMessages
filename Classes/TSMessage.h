//
//  TSMessage.h
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import <UIKit/UIKit.h>

// NS_ENUM is now the preferred way to do typedefs. It gives the compiler and debugger more information, which helps everyone.
// When using SDK 6 or later, NS_ENUM is defined by Apple, so this block does nothing.
// For SDK 5 or earlier, this is the same definition block Apple uses.
#ifndef NS_ENUM
#if (__cplusplus && __cplusplus >= 201103L && (__has_extension(cxx_strong_enums) || __has_feature(objc_fixed_enum))) || (!__cplusplus && __has_feature(objc_fixed_enum))
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#if (__cplusplus)
#define NS_OPTIONS(_type, _name) _type _name; enum : _type
#else
#define NS_OPTIONS(_type, _name) enum _name : _type _name; enum _name : _type
#endif
#else
#define NS_ENUM(_type, _name) _type _name; enum
#define NS_OPTIONS(_type, _name) _type _name; enum
#endif
#endif

@class TSMessageView;

typedef NS_ENUM(NSInteger, TSMessageNotificationType) {
    TSMessageNotificationTypeMessage = 0,
    TSMessageNotificationTypeWarning,
    TSMessageNotificationTypeError,
    TSMessageNotificationTypeSuccess
};
typedef NS_ENUM(NSInteger, TSMessageNotificationPosition) {
    TSMessageNotificationPositionTop = 0,
    TSMessageNotificationPositionBottom
};

/** This enum can be passed to the duration parameter */
typedef NS_ENUM(NSInteger,TSMessageNotificationDuration) {
    TSMessageNotificationDurationAutomatic = 0,
    TSMessageNotificationDurationEndless = -1 // The notification is displayed until the user dismissed it or it is dismissed by calling dismissActiveNotification
};


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

/** Shows a notification message view in a specific view controller
 @param messageView The message view to show
 */
+ (void)showNotification:(TSMessageView *)messageView;

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

/** Use this method to set a default view controller to display the messages in */
+ (void)setDefaultViewController:(UIViewController *)defaultViewController;

/** You can also override this in subclass instead of using setDefaultViewController */
+ (UIViewController *)defaultViewController;

@end
