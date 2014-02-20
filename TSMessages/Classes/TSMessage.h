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

#define TS_SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@class TSMessageView;

typedef NS_ENUM(NSInteger, TSMessageNotificationType) {
    TSMessageNotificationTypeMessage = 0,
    TSMessageNotificationTypeSuccess,
    TSMessageNotificationTypeWarning,
    TSMessageNotificationTypeError
};

typedef NS_ENUM(NSInteger, TSMessageNotificationPosition) {
    TSMessageNotificationPositionTop = 0,
    TSMessageNotificationPositionBottom
};

typedef NS_ENUM(NSInteger, TSMessageNotificationDuration) {
    TSMessageNotificationDurationAutomatic = 0,
    TSMessageNotificationDurationEndless = -1, // The notification is displayed until the user dismissed it or it is dismissed by calling dismissActiveNotification
};

typedef void (^TSMessageCallback)(TSMessageView *messageView);

@interface TSMessage : NSObject

+ (instancetype)sharedMessage;

+ (UIViewController *)defaultViewController;

/** Returns a message view for further customization

 @param title The title of the notification view
 @param subtitle The text that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 
 @return The message view
 */
+ (TSMessageView *)notificationWithTitle:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(TSMessageNotificationType)type;

/** Shows a notification right away and returns the message view

 @param title The title of the notification view
 @param subtitle The text that is displayed underneath the title
 @param type The notification type (Message, Warning, Error, Success)
 
 @return The message view
 */
+ (TSMessageView *)showNotificationWithTitle:(NSString *)title
                                    subtitle:(NSString *)subtitle
                                        type:(TSMessageNotificationType)type;

/** Returns a message view in a specific view controller for further customization
 
 @param title The title of the notification view
 @param subtitle The message that is displayed underneath the title (optional)
 @param image A custom icon image (optional)
 @param type The notification type (Message, Warning, Error, Success)
 @param viewController The view controller to show the notification in
 
 @return The message view
 */
+ (TSMessageView *)notificationWithTitle:(NSString *)title
                                subtitle:(NSString *)subtitle
                                   image:(UIImage *)image
                                    type:(TSMessageNotificationType)type
                        inViewController:(UIViewController *)viewController;

/** Shows a notification right away in a specific view controller and returns
 the message view
 
 @param title The title of the notification view
 @param subtitle The text that is displayed underneath the title
 @param image A custom icon image (optional)
 @param type The notification type (Message, Warning, Error, Success)
 @param viewController The view controller to show the notification in
 
 @return The message view
 */
+ (TSMessageView *)showNotificationWithTitle:(NSString *)title
                                    subtitle:(NSString *)subtitle
                                       image:(UIImage *)image
                                        type:(TSMessageNotificationType)type
                            inViewController:(UIViewController *)viewController;

/** Use this method to set a default view controller to display the messages in */
+ (void)setDefaultViewController:(UIViewController *)defaultViewController;

/** Use this method to use custom designs for your messages. */
+ (void)addCustomDesignFromFileWithName:(NSString *)fileName;

/** Fades out the currently displayed notification. If another notification is in the queue,
 the next one will be displayed automatically
 
 @return YES if the currently displayed notification was successfully dismissed.
 NO if no notification was currently displayed.
 */
+ (BOOL)dismissActiveNotification;

/** Indicates whether a notification is currently active.
 
 @return YES if a notification is currently being displayed.
         NO if no notification is currently being displayed.
 */
+ (BOOL)isNotificationActive;

/** Shows or enqueues the notification view. If there is a notification
 displayed currently, the notification view gets added to the end of the
 queue and displayed after its prior notifications are shown. If it is
 the only notification it gets shown right away.
 */
+ (void)showOrEnqueueNotification:(TSMessageView *)messageView;

/** Shows a permanent notification message.
 
 This differs from normal notifications in that permanent messages are not
 contained in the messages queue and can be displayed in addition to the
 other messages.
 
 Permanent notifications do not get dismissed automatically, hence they do
 not have a duration but have to be dismissed by the user or programmatically
 in one of the callbacks.
 */
+ (void)showPermanentNotification:(TSMessageView *)messageView;

@end
