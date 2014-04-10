//
//  TSMessageItem.h
//  Pods
//
//  Created by Fedya Skitsko on 4/4/14.
//
//

#import <UIKit/UIKit.h>
#import "TSMessageItem.h"

@interface TSMessageDefaultItem : TSMessageItem

@property (nonatomic, readwrite, copy) NSString *buttonTitle;

@property (copy, readwrite, nonatomic) void (^buttonSelectionHandler)(id item);

+ (instancetype)itemWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                        image:(UIImage *)image
                         type:(TSMessageNotificationType)notificationType
                     duration:(CGFloat)duration
             inViewController:(UIViewController *)viewController
                   atPosition:(TSMessageNotificationPosition)position
         canBeDismissedByUser:(BOOL)dismissingEnabled
                   tapHandler:(void(^)(id item))tapHandler
                  iconHandler:(void(^)(id item))iconHandler
                  buttonTitle:(NSString *)buttonTitle
             buttonTapHandler:(void(^)(id item))buttonHandler;

@end