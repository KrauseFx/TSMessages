//
//  TSMessage.h
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
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


#define TS_SYSTEM_VERSION_LESS_THAN(v)            ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@class TSMessageView;


/** Define on which position a specific TSMessage should be displayed */
@protocol TSMessageViewProtocol<NSObject>

@optional
/** Implement this method to pass a custom position for a specific message */
- (CGFloat)messageLocationOfMessageView:(TSMessageView *)messageView;

/** You can custimze the given TSMessageView, like setting its alpha or adding a subview */
- (void)customizeMessageView:(TSMessageView *)messageView;

@end



typedef NS_ENUM(NSInteger, TSMessageNotificationType) {
    TSMessageNotificationTypeMessage = 0,
    TSMessageNotificationTypeWarning,
    TSMessageNotificationTypeError,
    TSMessageNotificationTypeSuccess
};
typedef NS_ENUM(NSInteger, TSMessageNotificationPosition) {
    TSMessageNotificationPositionTop = 0,
    TSMessageNotificationPositionNavBarOverlay,
    TSMessageNotificationPositionBottom
};

/** This enum can be passed to the duration parameter */
typedef NS_ENUM(NSInteger,TSMessageNotificationDuration) {
    TSMessageNotificationDurationAutomatic = 0,
    TSMessageNotificationDurationEndless = -1 // The notification is displayed until the user dismissed it or it is dismissed by calling dismissActiveNotification
};


@interface TSMessage : NSObject

/** By setting this delegate it's possible to set a custom offset for the notification view */
@property (nonatomic, assign) id <TSMessageViewProtocol>delegate;

+ (instancetype)sharedMessage;

+ (UIViewController *)defaultViewController;

/** Shows a notification message
 @param message The title of the notification view
 @param type The notification type (Message, Warning, Error, Success)
 */
+ (void)showNotificationWithTitle:(NSString *)message
                             type:(TSMessageNotificationType)type;

/** Shows a notification message
 @param title The title of the notification view
 @param subtitle The text that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 */
+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             type:(TSMessageNotificationType)type;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 You can use +setDefaultViewController: to set the the default one instead
 @param title The title of the notification view
 @param subtitle The text that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(TSMessageNotificationType)type;

/** Shows a notification message in a specific view controller with a specific duration
 @param viewController The view controller to show the notification in.
 You can use +setDefaultViewController: to set the the default one instead
 @param title The title of the notification view
 @param subtitle The text that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 @param duration The duration of the notification being displayed
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(TSMessageNotificationType)type
                                duration:(NSTimeInterval)duration;

/** Shows a notification message in a specific view controller with a specific duration
 @param viewController The view controller to show the notification in.
 You can use +setDefaultViewController: to set the the default one instead
 @param title The title of the notification view
 @param subtitle The text that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 @param duration The duration of the notification being displayed
 @param dismissingEnabled Should the message be dismissed when the user taps/swipes it
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(TSMessageNotificationType)type
                                duration:(NSTimeInterval)duration
                     canBeDismissedByUser:(BOOL)dismissingEnabled;



/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param subtitle The message that is displayed underneath the title (optional)
 @param image A custom icon image (optional)
 @param type The notification type (Message, Warning, Error, Success)
 @param duration The duration of the notification being displayed
 @param callback The block that should be executed, when the user tapped on the message
 @param buttonTitle The title for button (optional)
 @param buttonCallback The block that should be executed, when the user tapped on the button
 @param messagePosition The position of the message on the screen
 @param dismissingEnabled Should the message be dismissed when the user taps/swipes it
 */
+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                   image:(UIImage *)image
                                    type:(TSMessageNotificationType)type
                                duration:(NSTimeInterval)duration
                                callback:(void (^)())callback
                             buttonTitle:(NSString *)buttonTitle
                          buttonCallback:(void (^)())buttonCallback
                              atPosition:(TSMessageNotificationPosition)messagePosition
                    canBeDismissedByUser:(BOOL)dismissingEnabled;

/** Fades out the currently displayed notification. If another notification is in the queue,
 the next one will be displayed automatically
 @return YES if the currently displayed notification was successfully dismissed. NO if no notification
 was currently displayed.
 */
+ (BOOL)dismissActiveNotification;

/** Fades out the currently displayed notification with a completion block after the animation has finished. If another notification is in the queue,
 the next one will be displayed automatically
 @return YES if the currently displayed notification was successfully dismissed. NO if no notification
 was currently displayed.
 */
+ (BOOL)dismissActiveNotificationWithCompletion:(void (^)())completion;

/** Use this method to set a default view controller to display the messages in */
+ (void)setDefaultViewController:(UIViewController *)defaultViewController;

/** Set a delegate to have full control over the position of the message view */
+ (void)setDelegate:(id<TSMessageViewProtocol>)delegate;

/** Use this method to use custom designs in your messages. */
+ (void)addCustomDesignFromFileWithName:(NSString *)fileName;

/** Indicates whether a notification is currently active. */
+ (BOOL)isNotificationActive;

/** Returns the currently queued array of TSMessageView */
+ (NSArray *)queuedMessages;

/** Prepares the notification view to be displayed in the future. It is queued and then
 displayed in fadeInCurrentNotification.
 You don't have to use this method. */
+ (void)prepareNotificationToBeShown:(TSMessageView *)messageView;

/** Indicates whether currently the iOS 7 style of TSMessages is used
 This depends on the Base SDK and the currently used device */
+ (BOOL)iOS7StyleEnabled;

/** Indicates whether the current navigationBar is hidden by isNavigationBarHidden 
 on the UINavigationController or isHidden on the navigationBar of the current 
 UINavigationController */
+ (BOOL)isNavigationBarInNavigationControllerHidden:(UINavigationController *)navController;

@end
