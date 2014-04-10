//  TSMessageItem.m
//  Pods
//
//  Created by Fedya Skitsko on 4/4/14.
//
//

#import "TSMessageItem.h"
#import "TSMessageView.h"

@implementation TSMessageItem

+ (instancetype)itemWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                        image:(UIImage *)image
                         type:(TSMessageNotificationType)notificationType
                     duration:(CGFloat)duration
             inViewController:(UIViewController *)viewController
                   atPosition:(TSMessageNotificationPosition)position
         canBeDismissedByUser:(BOOL)dismissingEnabled
                   tapHandler:(void(^)(id item))tapHandler
                  iconHandler:(void(^)(id item))iconHandler {
    return [[self alloc] initWithTitle:title subtitle:subtitle image:image type:notificationType duration:duration inViewController:viewController atPosition:position canBeDismissedByUser:dismissingEnabled tapHandler:tapHandler iconHandler:iconHandler];
}

-(id)initWithTitle:(NSString *)title
          subtitle:(NSString *)subtitle
             image:(UIImage *)image
              type:(TSMessageNotificationType)notificationType
          duration:(CGFloat)duration
  inViewController:(UIViewController *)viewController
        atPosition:(TSMessageNotificationPosition)position
canBeDismissedByUser:(BOOL)dismissingEnabled
        tapHandler:(void(^)(id item))tapHandler
       iconHandler:(void(^)(id item))iconHandler {
    
    if (self = [super init]) {
        self.title = title;
        self.subtitle = subtitle;
        self.image = image;
        self.messageType = notificationType;
        self.duration = duration;
        self.viewController = viewController;
        self.messagePosition = position;
        self.dismissingEnabled = dismissingEnabled;
        self.selectionHandler = tapHandler;
        self.iconSelectionHandler = iconHandler;
    }
    
    return self;
}

- (Class)classForView {
    if ([self isMemberOfClass:[TSMessageItem class]]) {
        return [TSMessageView class];
    } else {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
}

@end
