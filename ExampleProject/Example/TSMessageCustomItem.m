//
//  TSMessageCustomItem.m
//  Example
//
//  Created by Fedya Skitsko on 4/4/14.
//  Copyright (c) 2014 Toursprung. All rights reserved.
//

#import "TSMessageCustomItem.h"
#import "TSMessageCustomView.h"

@implementation TSMessageCustomItem

+ (instancetype)itemWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                         type:(TSMessageNotificationType)notificationType
             inViewController:(UIViewController *)viewController
                   tapHandler:(void(^)(TSMessageCustomItem *item))tapHandler
                  iconHandler:(void(^)(TSMessageCustomItem *item))iconHandler
               disclosureView:(UIView *)disclosureView
            disclosureHandler:(void(^)(TSMessageCustomItem *item))disclosureHandler {
    
    TSMessageCustomItem *item = [[TSMessageCustomItem alloc] initWithTitle:title subtitle:subtitle image:[UIImage imageNamed:@"closeIcon"] type:notificationType duration:3.0 inViewController:viewController atPosition:TSMessageNotificationPositionBottom canBeDismissedByUser:YES tapHandler:tapHandler iconHandler:iconHandler];
    item.disclosureView = disclosureView;
    item.disclosureSelectionHandler = disclosureHandler;
    
    return item;
}

- (Class)classForView {
    return [TSMessageCustomView class];
}

@end
