//
//  TSMessage.m
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "TSMessage.h"
#import "TSMessageView.h"
#import "TSMessageView+Private.h"

#define kTSMessageDisplayTime 1.5
#define kTSMessageAnimationDuration 0.3
#define kTSMessageExtraDisplayTimePerPixel 0.04

@interface TSMessage ()
@property (nonatomic, strong) NSMutableArray *messages;
@end

@implementation TSMessage

static TSMessage *_sharedMessage;
static BOOL _notificationActive;

__weak static UIViewController *_defaultViewController;

+ (TSMessage *)sharedMessage
{
    if (!_sharedMessage)
    {
        _sharedMessage = [[[self class] alloc] init];
    }
    
    return _sharedMessage;
}

- (id)init
{
    if ((self = [super init]))
    {
        _messages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Setup notifications

+ (TSMessageView *)notificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(TSMessageNotificationType)type
{
    return [self notificationWithTitle:title subtitle:subtitle image:nil type:type inViewController:self.defaultViewController];
}

+ (TSMessageView *)notificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image type:(TSMessageNotificationType)type inViewController:(UIViewController *)viewController
{
    TSMessageView *view = [[TSMessageView alloc] initWithTitle:title subtitle:subtitle image:image type:type];
    
    view.viewController = viewController;
    
    return view;
}

#pragma mark - Setup notifications and display them right away

+ (TSMessageView *)showNotificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(TSMessageNotificationType)type
{
    return [self showNotificationWithTitle:title subtitle:subtitle image:nil type:type inViewController:self.defaultViewController];
}

+ (TSMessageView *)showNotificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image type:(TSMessageNotificationType)type inViewController:(UIViewController *)viewController
{
    TSMessageView *view = [self notificationWithTitle:title subtitle:subtitle image:image type:type inViewController:viewController];
    
    [self showOrEnqueueNotification:view];
    
    return view;
}

#pragma mark - Displaying notifications

+ (void)showPermanentNotification:(TSMessageView *)messageView
{
    [[TSMessage sharedMessage] fadeInNotification:messageView];
}

+ (void)showOrEnqueueNotification:(TSMessageView *)messageView
{
    NSString *title = messageView.title;
    NSString *subtitle = messageView.subtitle;

    for (TSMessageView *n in [TSMessage sharedMessage].messages)
    {
        // avoid showing the same messages twice in a row
        BOOL equalTitle = ([n.title isEqualToString:title] || (!n.title && !title));
        BOOL equalSubtitle = ([n.subtitle isEqualToString:subtitle] || (!n.subtitle && !subtitle));
        
        if (equalTitle && equalSubtitle) return;
    }

    [[TSMessage sharedMessage].messages addObject:messageView];

    if (!_notificationActive)
    {
        [[TSMessage sharedMessage] fadeInCurrentNotification];
    }
}

+ (BOOL)dismissActiveNotification
{
    if (![TSMessage sharedMessage].currentNotification) return NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TSMessage sharedMessage] fadeOutCurrentNotification];
    });
    
    return YES;
}

+ (BOOL)isNotificationActive
{
    return _notificationActive;
}

#pragma mark - Customizing notifications

+ (void)addCustomDesignFromFileWithName:(NSString *)fileName
{
    [TSMessageView addNotificationDesignFromFile:fileName];
}

#pragma mark - Default view controller

+ (UIViewController *)defaultViewController
{
    __strong UIViewController *defaultViewController = _defaultViewController;
    
    if (!defaultViewController)
    {
        NSLog(@"TSMessages: It is recommended to set a custom defaultViewController that is used to display the notifications");
        defaultViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    return defaultViewController;
}

+ (void)setDefaultViewController:(UIViewController *)defaultViewController
{
    _defaultViewController = defaultViewController;
}

#pragma mark - Internals

- (TSMessageView *)currentNotification
{
    if (!self.messages.count) return nil;
    
    return [self.messages firstObject];
}

- (void)fadeInCurrentNotification
{
    if (!self.currentNotification) return;

    _notificationActive = YES;

    [self fadeInNotification:self.currentNotification];
}

- (void)fadeInNotification:(TSMessageView *)messageView
{
    [messageView prepareForDisplay];
    
    __block CGFloat verticalOffset = 0.0f;

    void (^addStatusBarHeightToVerticalOffset)() = ^void() {
        BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
        CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
        CGFloat offset = isPortrait ? statusBarSize.height : statusBarSize.width;
        verticalOffset += offset;
    };

    if ([messageView.viewController isKindOfClass:[UINavigationController class]] || [messageView.viewController.parentViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController;
        UIViewController *viewController = messageView.viewController;

        if ([viewController isKindOfClass:[UINavigationController class]])
        {
            navigationController = (UINavigationController *)viewController;
        }
        else
        {
            navigationController = (UINavigationController *)viewController.parentViewController;
        }

        viewController = [[navigationController childViewControllers] firstObject];
        
        BOOL isViewIsUnderStatusBar = ![viewController prefersStatusBarHidden];
        
        if (!isViewIsUnderStatusBar && navigationController.parentViewController == nil)
        {
            // strange but true
            isViewIsUnderStatusBar = ![navigationController isNavigationBarHidden];
        }
        
        if (![navigationController isNavigationBarHidden])
        {
            [navigationController.view insertSubview:messageView
                                               belowSubview:[navigationController navigationBar]];
            verticalOffset = [navigationController navigationBar].bounds.size.height;
            addStatusBarHeightToVerticalOffset();
        }
        else
        {
            [messageView.viewController.view addSubview:messageView];
            
            if (isViewIsUnderStatusBar)
            {
                addStatusBarHeightToVerticalOffset();
            }
        }
    }
    else
    {
        [messageView.viewController.view addSubview:messageView];
        addStatusBarHeightToVerticalOffset();
    }

    CGPoint toPoint;
    if (messageView.position == TSMessageNotificationPositionTop)
    {
        CGFloat navigationbarBottomOfViewController = 0;

        if (messageView.delegate && [messageView.delegate respondsToSelector:@selector(navigationbarBottomOfViewController:)])
        {
            navigationbarBottomOfViewController = [messageView.delegate navigationbarBottomOfViewController:messageView.viewController];
        }
        
        toPoint = CGPointMake(messageView.center.x, navigationbarBottomOfViewController + verticalOffset + CGRectGetHeight(messageView.frame) / 2.0);
    }
    else
    {
        CGFloat y = messageView.viewController.view.bounds.size.height - CGRectGetHeight(messageView.frame) / 2.0;
        
        if (!messageView.viewController.navigationController.isToolbarHidden)
        {
            y -= CGRectGetHeight(messageView.viewController.navigationController.toolbar.bounds);
        }
        
        toPoint = CGPointMake(messageView.center.x, y);
    }

    [UIView animateWithDuration:kTSMessageAnimationDuration + 0.1
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         messageView.center = toPoint;
                     }
                     completion:^(BOOL finished) {
                         messageView.messageFullyDisplayed = YES;
                     }];

    if (messageView.duration == TSMessageNotificationDurationAutomatic)
    {
        messageView.duration = kTSMessageAnimationDuration + kTSMessageDisplayTime + messageView.frame.size.height * kTSMessageExtraDisplayTimePerPixel;
    }

    if (messageView.duration != TSMessageNotificationDurationEndless)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(fadeOutCurrentNotification) withObject:nil afterDelay:messageView.duration];
        });
    }
}

- (void)fadeOutNotification:(TSMessageView *)messageView
{
    [self fadeOutNotification:messageView completion:NULL];
}

- (void)fadeOutNotification:(TSMessageView *)messageView completion:(void (^)())completion
{
    messageView.messageFullyDisplayed = NO;

    CGPoint fadeOutToPoint;
    
    if (messageView.position == TSMessageNotificationPositionTop)
    {
        fadeOutToPoint = CGPointMake(messageView.center.x, -CGRectGetHeight(messageView.frame)/2.f);
    }
    else
    {
        fadeOutToPoint = CGPointMake(messageView.center.x, messageView.viewController.view.bounds.size.height + CGRectGetHeight(messageView.frame)/2.f);
    }

    [UIView animateWithDuration:kTSMessageAnimationDuration animations:^{
         messageView.center = fadeOutToPoint;
     } completion:^(BOOL finished) {
         [messageView removeFromSuperview];

         if (completion) completion();
     }];
}

- (void)fadeOutCurrentNotification
{
    if (!self.currentNotification) return;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutCurrentNotification) object:nil];

    [self fadeOutNotification:self.currentNotification completion:^{
        if (self.messages.count)
        {
            [self.messages removeObjectAtIndex:0];
        }

        _notificationActive = NO;

        if (self.messages.count)
        {
            [self fadeInCurrentNotification];
        }
    }];
}

@end
