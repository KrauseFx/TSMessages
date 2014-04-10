//
//  TSMessageCustomItem.h
//  Example
//
//  Created by Fedya Skitsko on 4/4/14.
//  Copyright (c) 2014 Toursprung. All rights reserved.
//

#import "TSMessageItem.h"

@interface TSMessageCustomItem : TSMessageItem

@property (copy, readwrite, nonatomic) void (^disclosureSelectionHandler)(id item);
@property (copy, readwrite, nonatomic) UIView *disclosureView;

+ (instancetype)itemWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                         type:(TSMessageNotificationType)notificationType
             inViewController:(UIViewController *)viewController
                   tapHandler:(void(^)(TSMessageCustomItem *item))tapHandler
                  iconHandler:(void(^)(TSMessageCustomItem *item))iconHandler
               disclosureView:(UIView *)disclosureView
            disclosureHandler:(void(^)(TSMessageCustomItem *item))disclosureHandler;

@end
