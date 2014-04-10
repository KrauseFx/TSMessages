//
//  TSMessageItem.h
//  Pods
//
//  Created by Fedya Skitsko on 4/4/14.
//
//

#import <UIKit/UIKit.h>

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

@interface TSMessageItem : NSObject

/** The displayed title of this message */
@property (nonatomic, readwrite, copy) NSString *title;

/** The displayed subtitle of this message */
@property (nonatomic, readwrite, copy) NSString *subtitle;

/** The view controller this message is displayed in */
@property (nonatomic, readwrite, strong) UIViewController *viewController;

/** The duration of the displayed message. If it is 0.0, it will automatically be calculated */
@property (nonatomic, assign) CGFloat duration;

/** The position of the message (top or bottom) */
@property (nonatomic, assign) TSMessageNotificationPosition messagePosition;

/** Notification type */
@property (nonatomic, assign) TSMessageNotificationType messageType;

/** Is the message currently fully displayed? Is set as soon as the message is really fully visible */
@property (nonatomic, assign) BOOL messageIsFullyDisplayed;

/** Should this message be dismissed when the user taps/swipes it? */
@property (nonatomic, assign) BOOL dismissingEnabled;

@property (copy, readwrite, nonatomic) void (^selectionHandler)(id item);

@property (nonatomic, readwrite, copy) UIImage *image;
@property (copy, readwrite, nonatomic) void (^iconSelectionHandler)(id item);

+ (instancetype)itemWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                        image:(UIImage *)image
                         type:(TSMessageNotificationType)notificationType
                     duration:(CGFloat)duration
             inViewController:(UIViewController *)viewController
                   atPosition:(TSMessageNotificationPosition)position
         canBeDismissedByUser:(BOOL)dismissingEnabled
                   tapHandler:(void(^)(id item))tapHandler
                  iconHandler:(void(^)(id item))iconHandler;

-(id)initWithTitle:(NSString *)title
          subtitle:(NSString *)subtitle
             image:(UIImage *)image
              type:(TSMessageNotificationType)notificationType
          duration:(CGFloat)duration
  inViewController:(UIViewController *)viewController
        atPosition:(TSMessageNotificationPosition)position
canBeDismissedByUser:(BOOL)dismissingEnabled
        tapHandler:(void(^)(id item))tapHandler
       iconHandler:(void(^)(id item))iconHandler;

- (Class)classForView;

@end