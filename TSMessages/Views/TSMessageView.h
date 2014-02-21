//
//  TSMessageView.h
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessage.h"

#define TSMessageViewAlpha 0.95

@protocol TSMessageViewProtocol<NSObject>
@optional
/** Implement this method to pass a custom value for positioning the message view */
- (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController;
@end

@interface TSMessageView : UIView
/** The view controller this message is displayed in */
@property (nonatomic, weak) UIViewController *viewController;

/** Is the message currenlty fully displayed? Is set as soon as the message is really fully visible */
@property (nonatomic, readonly) BOOL isMessageFullyDisplayed;

/** The duration of the displayed message. If it is 0.0, it will automatically be calculated */
@property (nonatomic, assign) CGFloat duration;

/** The position of the message (top or bottom) */
@property (nonatomic, assign) TSMessagePosition position;

/** By setting this delegate it's possible to set a custom offset for the message view */
@property (nonatomic, assign) id <TSMessageViewProtocol> delegate;

/** The callback that should be invoked, when the user taps the message */
@property (nonatomic, copy) TSMessageCallback tapCallback;

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image type:(TSMessageType)type;

/** Dismisses this message view */
- (void)dismiss;

/** Adds a button with a callback that gets invoked when the button is tapped */
- (void)setButtonWithTitle:(NSString *)title callback:(TSMessageCallback)callback;

/** Enables dismissing the message by swiping */
- (void)setUserDismissEnabled;
- (void)setUserDismissEnabledWithCallback:(TSMessageCallback)callback;
@end
