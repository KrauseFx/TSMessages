//
//  TSMessageView.h
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessage.h"
#import "TSMessageItem.h"

#define TSMessageViewAlpha 0.95
#define TSMessageViewPadding 15.0

@protocol TSMessageViewDelegate <NSObject>
@optional
/** Implement this method to pass a custom value for positioning the message view */
- (CGFloat)navigationBarBottomOfViewController:(UIViewController *)viewController;
@end

@interface TSMessageView : UIView

@property (nonatomic, strong) TSMessageItem *item;

@property (nonatomic, assign) CGFloat textSpaceLeft;
@property (nonatomic, assign) CGFloat textSpaceRight;

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *contentLabel;
@property (nonatomic, readonly) UIImageView *iconImageView;

/** By setting this delegate it's possible to set a custom offset for the notification view */
@property(nonatomic, assign) id <TSMessageViewDelegate>delegate;

+ (CGFloat)heightWithItem:(TSMessageItem *)item;

+ (instancetype)messageWithItem:(TSMessageItem *)item;
- (id)initWithItem:(TSMessageItem *)item;

/** Fades out this notification view */
- (void)fadeMeOut;
- (void)setup;

@end
