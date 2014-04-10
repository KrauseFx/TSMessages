//  TSMessageItem.m
//  Pods
//
//  Created by Fedya Skitsko on 4/4/14.
//
//

#import "TSMessageDefaultItem.h"
#import "TSMessageDefaultView.h"

@implementation TSMessageDefaultItem

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
             buttonTapHandler:(void(^)(id item))buttonHandler {
    
    TSMessageDefaultItem *item = [[TSMessageDefaultItem alloc] initWithTitle:title subtitle:subtitle image:image type:notificationType duration:duration inViewController:viewController atPosition:position canBeDismissedByUser:dismissingEnabled tapHandler:tapHandler iconHandler:iconHandler];
    item.buttonTitle = buttonTitle;
    item.buttonSelectionHandler = buttonHandler;
    
    return item;
}

- (Class)classForView {
    return [TSMessageDefaultView class];
}

@end
